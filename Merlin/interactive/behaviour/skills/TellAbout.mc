# tell_about - respond to "tell me about X" by gathering the beliefs this NPC
# holds about X and TELLing them as one multi-belief payload.
#
# The grammar maps "tell me about <X>" (Statements.mgr) to
#   { ?asker goal {@self tell_about ?subject ?asker} }
# and the receiver internalises the payload via HearTell.mc's hear-tell rule:
#   (begin_belief (eval_msg ?msg)).
#
# utterable_beliefs_about_msg does the whole content-selection / wire-form
# / pressure-discharge job in a single rule-function call:
#  - recall ongoing beliefs about ?subject (tier-gated by speaker -> asker bond)
#  - inject any held {@self pressure ?kind} pressure-discharge beliefs
#    (unless {@self hate ?asker})
#  - rephrase every list item into communicable form ((o [n ...]) / (o [k ...]))
#  - wrap in (msg <list> (reg_des ...))
# The function returns the same list-symbol when contents are identical (lists
# dedup by hash on NPC minds), so re-evaluation each cycle is cheap and there's
# no compute/tell blackboard split.

rule tell-about
{@self tell_about ?subject ?asker}: ?tell
(none {@self /succ TELL ? ?asker /causes ~?tell})
   ->
# abs_util 1 prioritises answering the request over posing your own questions.
(maintain_goal {@self TELL (utterable_beliefs_about_msg ?subject ?asker) ?asker} (des abs_util 1)): ?response
# ?tell isn't a self-act, so its causal link must be added explicitly.
(add_causes ?response ?tell)
# No task in the header - forget the activation once it ceases.
(forget_on_cease).


rule tell-about-outcome
{@self tell_about ?subject ?asker}: ?tell
{@self /succ TELL ? ?asker /causes ~?tell}: ?TELL
    ->
(set_outcome ?tell (outcome ?TELL)).
