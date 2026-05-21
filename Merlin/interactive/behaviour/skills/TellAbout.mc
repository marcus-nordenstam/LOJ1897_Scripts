# tell_about - respond to "tell me about X" by gathering the beliefs this NPC
# holds about X and TELLing them as one multi-belief payload.
#
# Structure mirrors the compute/tell split of AnswerQuestion.mc:
#   tell-about-compute  selects the content ONCE (the beliefs_about rule-
#                       function mints a fresh list each call, so it must not
#                       run every cycle) and stashes the belief list on the
#                       private blackboard, keyed on the subject.
#   tell-about-tell     reads the list back, wraps it in utterable_msg (which
#                       rephrases mental objects into a communicable form so
#                       they survive the boundary), and proposes the TELL.
#
# The tell belief {?asker goal {@self tell_about ?subject ?asker}} is
# produced by the grammar from "tell me about <X>" (Statements.mgr).
# The receiver internalises the payload via HearTell.mc's hear-tell rule:
# (begin_belief (eval_msg ?msg)). See Docs/dialogue_nlg_plan.md Phase 2.


rule tell-about-compute
{@self tell_about ?subject ?asker}: ?tell
(bb_private_none ?subject tell_payload)
(none {@self /succ TELL ? ?asker /causes ~?tell})
(beliefs_about ?subject ?asker): ?belief_list
   ->
(bb_private_write ?subject tell_payload ?belief_list).


rule tell-about-tell
{@self tell_about ?subject ?asker}: ?tell
(bb_private_read ?subject tell_payload): ?msg
(none {@self /succ TELL ? ?asker /causes ~?tell})
   ->
# abs_util 1 prioritises answering the request over posing your own questions.
(maintain_goal {@self TELL (utterable_msg ?msg) ?asker} (des abs_util 1)): ?response
# ?tell isn't a self-act, so its causal link must be added explicitly.
(add_causes ?response ?tell)
# No task in the header - forget the activation once it ceases.
(forget_on_cease).


rule tell-about-outcome
{@self tell_about ?subject ?asker}: ?tell
{@self /succ TELL ? ?asker /causes ~?tell}: ?TELL
    ->
(set_outcome ?tell (outcome ?TELL)).
