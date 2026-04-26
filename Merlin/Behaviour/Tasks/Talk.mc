
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


# Splitting concerns into separate but parallel beliefs and bb entries:
#
# (a) Having a goal to talk to someone (to proactively TELL or ASK, or because we expect to be asked or expect an answer)
#     e.g. (goal {@self talk_to ?person}).  This can be used to propagate the cause-chain for utility purposes.
# (b) Knowing which message or question to to TELL or ASK (TELL/ASK belief)
# (c) Knowing in what cell to we are planning to uphold our end of the conversation, using bb: (talk_cell)
#
# Talking behaviour:
# * claim a cell within talk-range of your conversational partner, go to your cell, and stay there during talking.
# * carry multiple simultaneous conversations, but each individual TELL/ASK is executed sequentially 
# * talking can be done as long as your cell overlaps you, but always try to be at the center of the cell

# Ordering a beer:
# Patron/bartender - non interrupted
# Patron/bartender - patron interrupted (stops pubbing, or has to go to bathroom, or dies)
# Patron/bartender - bartender interruped (e.g. end of shift, has to go to bathroom, or dies)
#
# Player/bartender - non interrupted
# Player/bartender - player runs off in the middle of ordering
# Patron/bartender - bartender interruped (e.g. end of shift)
#
# Dialogue in general:
#
# NPC1 walking home, NPC2 tries to talk to them
# NPC1 talking to NPC2.  NPC3 (or Player) asks a question of NPC1.
# NPC1 and NPC2 are talking.  NPC1 dies in the middle of the conversation.

# ------------------------------------------------------------------------------------------------
# Determining the 'talk cell', e.g. the cell from which you will hold your end of the conversation
# ------------------------------------------------------------------------------------------------

# If I want to say some message to someone, I want to talk to them
rule talk-to-goal
{@self goal {@self TELL|ASK ? ?person}}
    ->
(maintainGoal {@self talk_to ?person}).

# If you want to talk to someone, signal that to them
rule talk-signal-try-to-talk
{@self goal {@self talk_to ?person}}
    ->
(bb_maintain @self try_to_talk_to ?person 10).

# If someone wants to talk to me and I am unprepared to talk to (e.g. I don't have a talk-cell for them)
# then claim a talk cell near their talk cell so we can talk
rule talk-recipient-claim-talk-cell
(bb_any ? try_to_talk_to @self /output_subject): ?person
(bb_none @self talk_cell)
(bb_read ?person talk_cell): ?their_talk_cell
(claim_env_cell /in_talk_range ?their_talk_cell): ?my_talk_cell
    ->
(beginGoal {@self talk_to ?person})
(bb_write @self talk_cell ?my_talk_cell)
(maintainAttention ?person).

# The rule that sets the goal to talk typically will also
# set the talk-cell, but if not, this is the general catch-call
rule talk-claim-talk-cell
{@self goal {@self talk_to ?person}}
(bb_none @self talk_cell)
(claim_env_cell /in_talk_range ?person): ?talk_cell
(lockRule talk 0)
    ->
(bb_write @self talk_cell ?talk_cell)
(maintainAttention ?person).

# ------------------------------------------------------------------------------------------------
# Ensuring I am in my talk cell
# ------------------------------------------------------------------------------------------------

# If I have a talk-cell and I'm not in it, go to it
rule talk-go-to-talk-cell
{@self goal {@self talk_to}}
(bb_read @self talk_cell): ?talk_cell
(at /not ?talk_cell)
    ->
# Intentionally higher utility than TURN_TO below, so the NPC
# continues into the center of the cell, if possible
(maintainProposal {@self go_env_cell ?talk_cell} /absUtil 1100).

# If I have a talk-cell and I'm in it, stay there and face the person you're talking to
rule talk-face-person-talking-to-me
{@self goal {@self talk_to ?person}}
(bb_read @self talk_cell): ?talk_cell
(overlaps ?talk_cell @self)
    ->
(maintainProposal {@self keep_looking_at_part ?person eyes} /absUtil 1000)
(maintainProposal {@self TURN_TO ?person} /absUtil 1000).

# If I have a talk-cell and I'm in it, go ahead and talk, 
# stay there and face the person you're talking to
rule talk-tell-or-ask-proposal
{@self goal {@self TELL|ASK ?msg ?person}:?talk_action}
(bb_read @self talk_cell): ?talk_cell
(overlaps ?talk_cell @self)
    ->
(beginProposal ?talk_action).

# ------------------------------------------------------------------------------------------------
# RELEASE
# ------------------------------------------------------------------------------------------------

# Release cell when I am no longer trying to talk to anyone AND
# nobody is trying to talk to me
rule talk-release-cell
(bb_read @self talk_cell): ?talk_cell
(none {@self goal {@self talk_to}})
(bb_none ? try_to_talk_to @self)
    ->
(unclaim_env_cell ?talk_cell)
(bb_clear @self talk_cell).

# ------------------------------------------------------------------------------------------------
# OUTCOMES
# ------------------------------------------------------------------------------------------------

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
