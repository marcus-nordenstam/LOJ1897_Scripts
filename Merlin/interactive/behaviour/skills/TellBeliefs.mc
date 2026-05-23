# tell_beliefs - respond to "tell me about X's <state_kind>" (the kind-
# quantified content request) by evaluating the target belief pattern as
# an implicit (every ...) search and TELLing the matching beliefs back.
#
# Grammar produces (Statements.mgr "tell me about $obj(NP) ++'s $state_kind"):
#   { ?_I goal { ?_you tell_beliefs { ?sub <state_kind> ? ? } ?_I } }
#
# The target slot of tell_beliefs is an INLINE BELIEF PATTERN - the query
# itself, not a function-call wrap. The (every ...) is implied by this
# rule; tasks are beliefs and beliefs can't carry function calls in their
# slots (the no-functions-in-belief-slots rule from CLAUDE.md). The
# pattern's label position carries a [k <state_kind>] kind constraint;
# the hstr-vs-kind matcher cell (match_symbols.h) matches stored hstr
# labels against the kind via ontology is_a.
#
# The compute rule destructures the inline query pattern into its four
# fields (sub / label_kind / tgt / aux) and runs (every) on a freshly-
# constructed pattern in the RESPONSE section. Putting (every ?var) in
# the condition would defeat alpha-network indexing of the search; the
# condition stays pure belief-pattern matching, the search runs once on
# rule firing with all bindings concrete.
#
# Structure mirrors TellAbout.mc's compute/tell/outcome split. The bb
# key is the inner tell_beliefs sentence (?tell) - unique per goal, stable
# across the compute->tell->outcome cycle.

rule tell-beliefs-compute
{@self tell_beliefs {?sub ?label_kind ?tgt ?aux} ?asker}: ?tell
(bb_private_none ?tell tell_beliefs_payload)
(none {@self /succ TELL ? ?asker /causes ~?tell})
   ->
(print "tell-beliefs-compute fired: sub= ?sub  label_kind= ?label_kind  asker= ?asker")
(every {?sub ?label_kind ?tgt ?aux}): ?belief_list
(print "tell-beliefs-compute: every-returned ?belief_list")
(bb_private_write ?tell tell_beliefs_payload ?belief_list).


rule tell-beliefs-tell
{@self tell_beliefs ?pattern ?asker}: ?tell
(bb_private_read ?tell tell_beliefs_payload): ?msg
(none {@self /succ TELL ? ?asker /causes ~?tell})
   ->
# abs_util 1 prioritises answering the request over posing your own
# questions. utterable_msg's 2nd arg (?asker) derives the speech-act
# register descriptor toward the listener so it rides the wire on the
# (msg ...) - plan Phase 2.
(maintain_goal {@self TELL (utterable_msg ?msg ?asker) ?asker} (des abs_util 1)): ?response
(add_causes ?response ?tell)
(forget_on_cease).


rule tell-beliefs-outcome
{@self tell_beliefs ?pattern ?asker}: ?tell
{@self /succ TELL ? ?asker /causes ~?tell}: ?TELL
    ->
(set_outcome ?tell (outcome ?TELL)).
