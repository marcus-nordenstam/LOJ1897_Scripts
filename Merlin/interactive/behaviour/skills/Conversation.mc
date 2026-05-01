
/*
# Starting a conversation with someone
{@self goal {@self conversation ?irr_conv}}
{?irr_conv participant !@self:?person}
(bb_clear_on_fail (bb_public_try_write_new @self talking_to ?person)
                  (bb_public_try_write_new ?person talking_to @self))
    ->
(realise ?irr_conv): ?realis_conv
(beginBelief {@self conversation ?realis_conv}).

# Realizing that someone is starting a conversation with your
(bb_public_read @self talking_to): ?person
(none {@self conversation.participant ?person})


# TELL action-handler should fail if the person you are TELLING to is too far away to hear (4+ cells away)
# So rules need to check that a TELL succeeded in their reasoning
#

#   Introduce a new function: bb_public_maintain which can be used to register slots that time out if not maintained after 
#   some time.  We can use this to represent that someone "has something to say" to someone else.
#       (bb_public_maintain @self wants_to_talk_to ?person 3) - for the next 3 seconds, I have something to say
#   if the bb_public_maintain function doesn't re-maintain/update that slot for 3 seconds, it automatically gets cleared.
#
#   The player-tell action handler would keep calling the mx_* version of that function to update 
#   (?player wants_to_talk_to ?npc) while the player is in dialogue mode, but regular npcs achieve it through their
#   tell/ask and dialogue rules it as part of their talking behaviour rules, so that conversations don't instantly die
#   in-between TELL and ASK actions.
#
#   When any slot is written into a blackboard (by any code-path, bb_public_write, bb_public_maintain, or mx_* or whatever), all
#   involved entities must be notified and keep a little list of entities who currently have slots in their blackboards
#   that involve me.  
#
#   Then we can efficiently implement (bb_public_any...) which can use wildcards, as follows: (bb_public_any ? wants_to_talk_to @self)
# - which returns true if ANYONE wants to talk to me.  It can be efficient becase each entity has a list of which 
#   entities are reffing me through a bb-slot.  Suppose there are 10,000 entities in the game but only 3 currently ref me
#   through a bb-slot, then to implement a wildcard in (bb_public_any...), I can just check those 3 entities' blackboards to 
#   see if the slot-label and value matches.  

# Armed with these things, we can now easily implement the following behaviour:
# * In order to TELL or ASK, you must be within 2-cell band of the person you're talking to
# * If you want to TELL or ASK someone anything, do (bb_public_maintain @self wants_to_talk_to ?person 3)
# * If you want to TELL or ASK someone anything, you must keep an updated claim a cell adjacent to the 
#   recipient and be in it, in order to say.
# * If you know that one or more people want to talk to you, claim the closest possible cell near you 
#   (including the cell you currently occupy) and remain in it - making yourself availble to talking.
# * If the initiator causes in the recipient a desire to respond, they will become the initator in the next turn,
#   and the above rules will apply in reverse.
# * If neither of the two are trying to talk after 3 seconds, the conversation naturally ends and they go on
#   with other tasks - unclaiming their 'talking cells'.


# ISSUES

# When an entity is destroyed, all claims for it should be cleared in the c++ cleanup code.
# (bb_public_none should allow 3 args, if the third is a non-wildcard, it must be used to match the value)



# --- WANTING TO TALK ---

# If I have a goal to TELL or ASK someone, maintain the signal, and update the desired spatial positioning
rule want-to-talk-tell
{@self goal {@self TELL ?msg ?person}}
# /reuse means to accept existing claims (for me) if they match the criteria
(claim_env_cell /reuse (in_talk_range_of_des ?person)): ?talk_cell
(lockRule talk) # we may have goals to talk to many, but only execute one talk at a time
    ->
# maintain pressure on the signal
(bb_public_maintain @self try_to_talk_to ?person 3)
# handle a moving target
(bb_public_read @self talk_cell) = ?old_cell
(if (neq ?old_cell ?talk_cell) (unclaim_env_cell ?old_cell))  # (unclaim...) should just no-op if the arg is not a cell at all, such as @fail
# keep track of the most up-to-date talk-cell
(bb_public_write @self talk_cell ?talk_cell)
(maintainAttention ?person).

rule want-to-talk-ask
{@self goal {@self ASK ?msg ?person}}
# /reuse means to accept existing claims (for me) if they match the criteria
(claim_env_cell /reuse (in_talk_range_of_des ?person)): ?talk_cell
(lockRule talk) # we may have goals to talk to many, but only execute one talk at a time
    ->
# maintain pressure on the signal
(bb_public_maintain @self try_to_talk_to ?person 3)
# handle a moving target
(bb_public_read @self talk_cell) = ?old_cell
(if (neq ?old_cell ?talk_cell) (unclaim_env_cell ?old_cell))  # (unclaim...) should just no-op if the arg is not a cell at all, such as @fail
# keep track of the most up-to-date talk-cell
(bb_public_write @self talk_cell ?talk_cell)
(maintainAttention ?person).


# Someone wants to talk to me: claim my current cell or somewhere very close by
rule talk-recipient-claim
(bb_public_any ? try_to_talk_to @self)
(bb_public_none @self talk_cell)
(claim_env_cell /reuse (at_or_near_des @self)): ?talk_cell # (at_or_near_des means) accept cells occupied by intended-occupier 
    ->
(bb_public_write @self talk_cell ?talk_cell).


# If I have a talk-cell, then stay in it 
# (regardless if I'm trying to talk, or someone is talking to me)
rule talk-stay-in-cell
(bb_public_read @self talk_cell): ?talk_cell
(overlaps ?talk_cell /not @self)
    ->
(maintain_proposal {@self go_cell ?talk_cell} (des abs_util 1000)).


# Release cell when I am no longer trying to talk to anyone AND
# nobody is trying to talk to me
rule talk-release-cell
(bb_public_read @self talk_cell): ?talk_cell
(bb_public_none ? try_to_talk_to @self)
(bb_public_none @self try_to_talk_to ?)
    ->
(unclaim_env_cell ?talk_cell)
(bb_public_clear @self talk_cell).


# --- TELL/ASK EXECUTION ---

# Propose TELL when in range and in my claimed cell
rule TELL-propose
{@self goal {@self TELL ?msg ?person}}
(bb_public_read @self talk_cell)
(in_range /talk @self ?person)
    ->
(begin_proposal {@self TELL ?msg ?person}).

rule ASK-propose
{@self goal {@self ASK ?question ?person}}
(bb_public_read @self talk_cell)
(in_range /talk @self ?person)
    ->
(begin_proposal {@self ASK ?question ?person}).





# I WANT to have a private conversation with ?person
#{@self goal {@self conversation ?conv}}
#{?conv isa [k privateConv]}
#{?conv participant !@self:?person}

#-----------------------------------------------------------------------------------------
# If we want to have a conversation with someone, we must first determine if that person is 
# already in a conversation, or not.
#-----------------------------------------------------------------------------------------
rule start-conv-perceive-conv-proposal /breakOnFire
{@self goal {@self conversation ?irrConv}}
{?irrConv participant !@self:?person}
(none {?person conversation}) # We don't know if ?person is already in a conversation
    ->
# If they're too far away to observe (or imaginary), then we could just always assume they're NOT in a conversation.
(maintain_proposal {@self perceive_attr ?person conversation}).


#-----------------------------------------------------------------------------------------
# STARTING A CONVERSATION
#-----------------------------------------------------------------------------------------

rule start-conv-proposal
{@self goal {@self conversation ?irrConv}}
{@self conversation _}
{?irrConv participant !@self:?person}
{?person conversation _} # We know that ?person is NOT in ANY conversation
(lockRule) # Only try to start one conv at a time
    ->
(maintain_proposal {@self start_conv ?irrConv})
(print [@self wants to start a conversation with ?person]).


rule start-conv-maintain-closeAndFacing-proposal
{@self start_conv ?conv}
{?conv participant !@self:?person}
    ->
(maintain_proposal {@self keep_near_and_facing ?person} (des abs_util 1000))
(maintain_proposal {@self keep_looking_at_part ?person eyes} (des abs_util 1000)).


rule start-conv-tell-how_do-proposal
{@self start_conv ?conv}
{?conv participant !@self:?person}
    ->
(anyOrUnknown {?person name}).target: ?nameOrUnknown
(formulaic opening how_do ?nameOrUnknown): ?opening
(maintain_goal {@self TELL ?opening ?person}).


rule start-conv-makeConvFromResponse-proposal
{@self start_conv ?irrConv}: ?start_conv
{?irrConv participant !@self:?person}
{@self /succ TELL ? ?person /causes ~?start_conv}: ?openingTELL
{?person /succ TELL (formulaic response how_do ?) @self /causes ~?openingTELL}
    ->
# Create the realis conversation (which is a meta-entity)
(begin_proposal {@self MAKE_CONV_META_ENT ?person @self}).


# I am trying to start a conversation with ?person,
# but ?person beats me to TELLing the formulaic opening
rule start-conv-makeConvPreemptive-proposal
{@self start_conv ?irrConv}: ?start_conv
{?irrConv participant !@self:?person}
{?person /succ TELL (formulaic opening ? ?) @self}
    ->
# Create the realis conversation (which is a meta-entity)
(begin_proposal {@self MAKE_CONV_META_ENT ?person @self})
(break).


# NOTE that we don't need to end the goal to have the irrealis
# conversation since that goal is maintained only while we are not
# in a (realis) conversation with someone.  But if this rule fires,
# then we are now in a conversation with someone, so the goal will
# have already ended.
rule realise-conv
{@self /ever start_conv ?irrConv /causes ?causes}: ?start_conv
{?irrConv participant !@self:?person}
{@self conversation @something:?reaConv}
{?person conversation ?reaConv}
    ->
# The conversation starting task was successful
(set_outcome ?start_conv /succ)
# The irrealis conv is the same as the realis conv
# NOTE that this also ends all possessive ?irrConv beliefs
# and leads to ?irrConv being forgotten
(reconcile ?irrConv ?reaConv)
# While this real conversation is occurring, keep close and personal with the participant
(maintain_proposal {@self keep_near_and_facing ?person} (des abs_util 1000)): ?keep_near_and_facing
(maintain_proposal {@self keep_looking_at_part ?person eyes} (des abs_util 1000)): ?keep_looking_at_part
(add_causes ?keep_near_and_facing ?causes)
(add_causes ?keep_looking_at_part ?causes).

# Failure scenarios:

# Person tells me they're busy with another conversation.
# This could happen if multiple NPCs try to start a conversation at the same
# time with one person. 
rule start-conv-outcome-fail /breakOnFire
{@self start_conv ?irrConv}: ?start_conv
{?irrConv participant !@self:?person}
{@self /succ TELL ? ?person /causes ~?start_conv}: ?openingTELL
{?person /succ TELL (formulaic refusal ? ?) @self /causes ~?openingTELL}
    ->
(set_outcome ?start_conv /fail).

# if {@self initiate_conversation ?person}
# and ?person declines your invitation in a rude manner (rude declining phrase, ignore, walk away)
# then
#   /begin ?person doesn't like you
#   (this realization may cancel the motivation to talk to them)

# if {@self initiate_conversation ?person}
# ?person does NOT join another conversation (or any conversation)
# but informs you that they cannot talk now; they can talk later
# then
#   /begin {john available_to_talk /i @now+1h @now+2h} (which ends the previous availability state via contradiction)

*/

#-----------------------------------------------------------------------------------------
# JOINING A CONVERSATION
#-----------------------------------------------------------------------------------------

/*
rule 
{@self goal {@self conversation ?conv}}
{?conv participant !@self:?person}
{?person conversation @something:?personsConv} # We know that ?person is in a conversation
(none {@self join_conv})
(lockRule) # Only try to join one conv at a time
    ->
(begin_proposal {@self join_conv ?personsConv}).

#-----------------------------------------------------------------------------------------
# RESPONDING TO A FORMULAIC OPENING (conversation starter)
#-----------------------------------------------------------------------------------------

rule conv-response-formulaicOpening-proposal
{@self conversation _}
{?person /succ TELL (formulaic opening how_do ?) @self}: ?personTell
(none {@self /ever TELL ? ?person /causes ~?personTell})
(lockRule) # Join only one conversation at a time
    ->
(anyOrUnknown {?person name}).target: ?nameOrUnknown
(formulaic response how_do ?nameOrUnknown): ?greeting
(begin_goal {@self TELL ?greeting ?person}): ?tellGreeting
(add_causes ?tellGreeting ?personTell).


# Player presses 'T' to talk — the game injects a player_talk formulaic opening.
# The NPC responds with "Yes?" and creates the conv meta-entity with the PLAYER
# as initiator, so conv-end-proposal ({?conv initiator @self}) won't match for
# the NPC — the conversation persists until the player exits dialogue.
rule conv-response-player_talk-proposal
{@self conversation _}
{?person /succ TELL (formulaic opening player_talk) @self}: ?personTell
(none {@self end_conv}) # Don't start a new conversation while ending one
(none {@self /ever TELL ? ?person /causes ~?personTell})
(lockRule) # Join only one conversation at a time
    ->
(formulaic response player_talk): ?greeting
(begin_goal {@self TELL ?greeting ?person}): ?tellGreeting
(add_causes ?tellGreeting ?personTell)
(begin_proposal {@self MAKE_CONV_META_ENT ?person ?person}).




rule conv-player_talk-maintain-closeAndFacing-proposal
{@self conversation @something:?conv}
{!@self:?person conversation ?conv}
{?person role player}
    ->
(maintain_proposal {@self keep_near_and_facing ?person} (des abs_util 1000))
(maintain_proposal {@self keep_looking_at_part ?person eyes} (des abs_util 1000)).


# Player presses 'Bye' — the game injects a player_bye formulaic leave-taking.
# The NPC begins end_conv through the normal proposal flow.
# We use begin_proposal (one-shot) + add_causes so the guard below can prevent
# re-matching the same old player_bye TELL on future conversations.
rule conv-response-player_bye-proposal
{@self conversation @something:?conv}
{!@self:?person conversation ?conv}
{?person /succ TELL (formulaic leave_taking player_bye) @self}: ?personTell
(none {@self /ever end_conv /causes ~?personTell})
    ->
(begin_proposal {@self end_conv ?conv} (des abs_util 1000)): ?proposal
(add_causes ?proposal ?personTell).


rule conv-response-refuseConv-proposal #/breakOnFire
{@self conversation @something:?conv}: ?talking
#{?person /succ TELL (formulaic opening ? ?) @self /beforeOrDuring ?talking}: ?personTell
{?person /succ TELL (formulaic opening ? ?) @self}: ?personTell
{?person conversation !?conv}
#(none {@self proposal {@self MAKE_CONV_META_ENT ?person}}) # don't refuse the person you are about to start a conversation with...
(none {@self /ever TELL ? ?person /causes ~?personTell})
    ->
(formulaic refusal ?talking): ?refusal
(begin_goal {@self TELL ?refusal ?person}): ?tellRefusal
(add_causes ?tellRefusal ?personTell).

#-----------------------------------------------------------------------------------------
# CONVERSATIONAL BEHAVIOUR
#-----------------------------------------------------------------------------------------

rule conv-todo-act-proposal
{@self conversation @something:?conv}
{?conv todo ?act /causes ?causes}
(lockRule) # only one todo-act at a time
    ->
(maintain_proposal ?act): ?proposal
(add_causes ?proposal ?causes) # add expl. cause because there are no task/goal conditions
(if (eq ?act.label ASK) 
    (beginBelief {@self expect_answer ?act.auxiliary /causes ?causes})).


# We need this separate rule to ensure that the expect-answer belief's causes includes
# the actual TELL-action belief, and not the tell-todo (which is just a clause)
rule conv-expect-answer-cause
{@self conversation @something:?conv}
{?conv todo {@self ASK ? ?audience} /causes ?causes}
{@self /ever ASK ? ?audience /causes ?causes}: ?ask
{@self expect_answer ?audience /causes ?causes}: ?expect_answer
    ->
(add_causes ?expect_answer ?ask).

#-----------------------------------------------------------------------------------------
# ENDING A CONVERSATION
#-----------------------------------------------------------------------------------------


# TODO:
#   Introduce a group object - which we use instead of lists
#   Introduce an 'audience' relation for conversations
#   Audience NEVER includes the @self, so it's a different group for each conversation member
#   That way we can deal with private vs group conversations without dealing with lists
#   Can also be used for all kinds of group activity rules
#   Example:
#       {conv audience aud}
#       {aud member sam}
#       {aud member bob}


# TODO: Don't end if the other person is displaying body-language 
# to the effect that they have more to say.

rule end-conv-proposal
{@self conversation @something:?conv}
{!@self:?audience conversation ?conv}
# Only let the person who initiated the conversation end it
{?conv initiator @self}
# Don't end a conversation if you're waiting on an answer
(none {@self expect_answer ?audience})
# Don't end a conversation until you've said/done everything you intended
(none {?conv todo})
#(gt (evalCount) 20 /cont) # how many times this instruction has been evaluated since the rule activated
    ->
(maintain_proposal {@self end_conv ?conv} (des rel_util 100)).


rule end-conv-tellLeaveTaking-proposal
{@self end_conv ?conv}: ?end_conv
{!@self:?person conversation ?conv}
    ->
# "we'll continue this later", "pardon me", "excuse me", "I have to go now", "bye", "see you later", etc.
(formulaic leave_taking bye): ?leave_taking
(begin_goal {@self TELL ?leave_taking ?person} (des rel_util 100)): ?tellGoal
(add_causes ?tellGoal ?end_conv).


# Only destroy the conversation AFTER leavetaking TELL has concluded
rule end-conv-destroyAfterTell-proposal
{@self /ever end_conv ?conv}: ?end_conv
{@self /past TELL ? ? /causes ~?end_conv} # we simply use /past instead of /succ in case it gets interrupted
    ->
(begin_proposal {@self DESTROY_CONV_META_ENT ?conv} (des rel_util 100)).


rule end-conv-outcome-succ
{@self end_conv ?conv}: ?end_conv
{@self /succ DESTROY_CONV_META_ENT ?conv}
    ->
(set_outcome ?end_conv /succ).

*/

# DEBUGGING RULES
/*
rule
{@self conversation _}
    ->
(print ["--- " @self is NOT in a conversation]).

rule
{@self conversation @something}
    ->
(print ["+++ " @self IS in a conversation]).

rule
{!@self:?person conversation _}
    ->
(print [" - " @self believes that ?person is NOT in a conversation]).

rule
{!@self:?person conversation @something}
    ->
(print [" + " @self believes that ?person IS in a conversation]).
*/

