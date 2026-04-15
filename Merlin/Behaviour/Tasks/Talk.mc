
# Talk.mc — Proximity-based TELL/ASK with bb_maintain coordination.
#
# No conversation meta-entities. Conversations arise naturally from the
# interplay of bb_maintain signals and cell claims:
#   - If you want to TELL/ASK someone, maintain a signal and claim a cell near them.
#   - If someone signals they want to talk to you, claim your current cell and stay put.
#   - If neither party maintains the signal for 3 seconds, everything auto-releases.
#
# The TELL/ASK action system handles one speech act at a time (lockRule talk 0).
# Multiple concurrent conversations are allowed — the lock only serializes the
# physical act of speaking.


# =============================================================================
# TRYING TO TALK
# =============================================================================

# If I have a goal to TELL someone, maintain the signal and update positioning
rule want-to-talk-tell
{@self goal {@self TELL ?msg ?person}}
(claim_env_cell /reuse /in_talk_range ?person): ?talk_cell
(lockRule talk 0)
    ->
(bb_maintain @self try_to_talk_to ?person 180)
(bb_read @self talk_cell) = ?old_cell
(if (neq ?old_cell ?talk_cell) (unclaim_env_cell ?old_cell))
(bb_write @self talk_cell ?talk_cell)
(maintainAttention ?person).

# If I have a goal to ASK someone, same as TELL
rule want-to-talk-ask
{@self goal {@self ASK ?question ?person}}
(claim_env_cell /reuse /in_talk_range ?person): ?talk_cell
(lockRule talk 0)
    ->
(bb_maintain @self try_to_talk_to ?person 180)
(bb_read @self talk_cell) = ?old_cell
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
(claim_env_cell /reuse /at_or_near @self): ?talk_cell
    ->
(bb_write @self talk_cell ?talk_cell).


# =============================================================================
# SPATIAL MOVEMENT
# =============================================================================

# If I have a talk-cell and I'm not in it, go to it
rule talk-stay-in-cell
(bb_read @self talk_cell): ?talk_cell
(overlaps ?talk_cell /not @self)
    ->
(maintainProposal {@self go_env_cell ?talk_cell} /absUtil 1000).


# =============================================================================
# RELEASE
# =============================================================================

# Release cell when I am no longer trying to talk to anyone AND
# nobody is trying to talk to me
rule talk-release-cell
(bb_read @self talk_cell): ?talk_cell
(bb_none ? try_to_talk_to @self)
(bb_none @self try_to_talk_to ?)
    ->
(unclaim_env_cell ?talk_cell)
(bb_clear @self talk_cell).


# =============================================================================
# TELL EXECUTION
# =============================================================================

# Propose TELL when spatial conditions are met (talk cell + in range)
rule TELL-propose-spatial
{@self goal {@self TELL ?msg ?person}}
(bb_read @self talk_cell)
(in_range /talk @self ?person)
    ->
(beginProposal {@self TELL ?msg ?person}).

# Fallback: propose TELL when no spatial system is available (no talk_cell ever claimed)
rule TELL-propose-nonspatial
{@self goal {@self TELL ?msg ?person}}
(bb_none @self talk_cell)
(lockRule talk 0)
    ->
(beginProposal {@self TELL ?msg ?person}).

# Track TELL outcome
rule goal-TELL-outcome
{@self goal {@self TELL ?msg ?audience}}: ?goal
{@self /past TELL ?msg ?audience /causes ~?goal /out?}: ?TELL
    ->
(setOutcome ?goal /from ?TELL).


# =============================================================================
# ASK EXECUTION
# =============================================================================

# Propose ASK when I'm in my talk cell and the person is in range
rule ASK-propose
{@self goal {@self ASK ?question ?person}}
(bb_read @self talk_cell)
(in_range /talk @self ?person)
    ->
(beginProposal {@self ASK ?question ?person}).

# Track ASK outcome
rule goal-ASK-outcome
{@self goal {@self ASK ?question ?audience}}: ?goal
{@self /past ASK ?question ?audience /causes ~?goal /out?}: ?ASK
    ->
(setOutcome ?goal /from ?ASK).

# When asking a question, expect an answer
rule ASK-expect-answer
{@self goal {@self ASK ?question ?person}}: ?goal
{@self /succ ASK ?question ?person /causes ~?goal}: ?ask
    ->
(beginBelief {@self expect answer ?person /causes ?ask}).
