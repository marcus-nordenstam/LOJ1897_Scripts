
# Talk.mc — Proximity-based TELL/ASK with bb_maintain coordination.
#
# Conversations arise naturally from the interplay of bb_maintain signals and cell claims:
#   - If you want to TELL/ASK someone, maintain a signal and claim a cell near them.
#   - If someone signals they want to talk to you, claim your current cell and stay put.
#   - If neither party maintains the signal for 3 seconds, everything auto-releases.
#
# The TELL/ASK action system handles one speech act at a time (lockRule talk...).
# Multiple concurrent conversations are allowed — the lock only serializes the
# physical act of speaking.

# copy <override_talk_cell ?old_cell ?new_cell ?person>
#    (bb_read @self talk_cell) = ?old_cell
#    (if (neq ?old_cell ?preempted_talk_cell) (unclaim_env_cell ?old_cell))
#    (bb_maintain @self try_to_talk_to ?person 30)
#    (bb_write @self talk_cell ?preempted_talk_cell)
#    (bb_clear @self preempted_talk_cell)
#    (maintainAttention ?person).



# =============================================================================
# TRYING TO TALK
# =============================================================================

# If some other rule is preempting the talk_cell, give it higher priority
rule want-to-talk-preempted
{@self goal {@self TELL|ASK ? ?person}}
(bb_read @self preempted_talk_cell): ?preempted_talk_cell
(lockRule talk 1)
    ->
#paste <override_talk_cell ?old_cell ...>
(bb_read @self talk_cell) = ?old_cell
(if (neq ?old_cell ?preempted_talk_cell) (unclaim_env_cell ?old_cell))
(bb_write @self try_to_talk_to ?person 30)
(bb_write @self talk_cell ?preempted_talk_cell)
(bb_clear @self preempted_talk_cell)
(maintainAttention ?person).

# This is the general fallback - no preemtive talk_cell exists
rule want-to-talk-general /cont-interval 1 0
{@self goal {@self TELL|ASK ? ?person}}
(bb_read @self talk_cell) = ?old_cell # using '=' instead of ':' so the condition won't fail if ?old_cell is @fail
(claim_env_cell /in_talk_range ?person /try ?old_cell): ?talk_cell
(lockRule talk 0) 
    ->
(bb_maintain @self try_to_talk_to ?person 30)
(if (neq ?old_cell ?talk_cell) (unclaim_env_cell ?old_cell))
(bb_write @self talk_cell ?talk_cell)
(maintainAttention ?person).


# =============================================================================
# SPATIAL SETUP (recipient)
# =============================================================================

# Someone wants to talk to me: claim my current cell or somewhere very close by
rule talk-recipient-claim
(bb_any ? try_to_talk_to @self)
(bb_none @self talk_cell)
(claim_env_cell /at_or_near @self): ?talk_cell
    ->
(bb_write @self talk_cell ?talk_cell).


# =============================================================================
# SPATIAL MOVEMENT
# =============================================================================

# If I have a talk-cell and I'm not in it, go to it
rule talk-go-to-talk-cell
{@self goal {@self TELL|ASK ? ?person}}
(bb_read @self talk_cell): ?talk_cell
(overlaps ?talk_cell /not @self)
    ->
(maintainProposal {@self go_env_cell ?talk_cell} /absUtil 1000).

# If I have a talk-cell and I'm in it, go ahead and talk, 
# stay there and face the person you're talking to
rule talk-face-person
{@self goal {@self TELL|ASK ?msg ?person}:?talk_action}
(bb_read @self talk_cell): ?talk_cell
(overlaps ?talk_cell @self)
    ->
(beginProposal ?talk_action)
(maintainProposal {@self TURN_TO ?person} /absUtil 1000).

# If I have a talk-cell and I'm in it, stay there and face the person you're talking to
rule talk-face-person-talking-to-me
(bb_read @self talk_cell): ?talk_cell
(bb_any ? try_to_talk_to @self /output_subject): ?person
(overlaps ?talk_cell @self)
    ->
(maintainProposal {@self TURN_TO ?person} /absUtil 1000).

# =============================================================================
# RELEASE
# =============================================================================

# Release cell when I am no longer trying to talk to anyone AND
# nobody is trying to talk to me
rule talk-release-cell
(bb_read @self talk_cell): ?talk_cell
(none {@self goal {@self TELL|ASK}})
(bb_none ? try_to_talk_to @self)
    ->
(unclaim_env_cell ?talk_cell)
(bb_clear @self try_to_talk_to)
(bb_clear @self talk_cell).


# =============================================================================
# OUTCOMES
# =============================================================================

# Track TELL outcome
rule goal-TELL-outcome
{@self goal {@self TELL ?msg ?audience}}: ?goal
{@self /past TELL ?msg ?audience /causes ~?goal /out?}: ?TELL
    ->
(setOutcome ?goal /from ?TELL).

# Track ASK outcome
# When asking a question, expect an answer
rule goal-ASK-outcome
{@self goal {@self ASK ?question ?person}}: ?goal
{@self /past ASK ?question ?person /causes ~?goal /out?}: ?ASK
    ->
(beginBelief {@self expect_answer ?person /causes ?ASK})
(setOutcome ?goal /from ?ASK).
