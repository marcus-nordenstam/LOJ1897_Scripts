
# Questions may only be asked if they are part of an ongoing conversation:
#
# The following two rules handles the case where I want to ask a question 
# to someone whom I am NOT currently in a conversation with.  
#
# This means we must set a goal go have a conversation with them (an irrealis 
# conversation since it hasn't happened yet).

/*

rule goal-conv-ASK-notAvail
{@self goal {@self ASK ?question ?audience}:?ask}: ?goal
{@self conversation ?myConv}
{?audience conversation !?myConv}
    ->
(o /hyp [k conversation] {@o participant @self} {@o participant ?audience}): ?irrConv
(maintainBelief {?irrConv todo ?ask /causes ?goal}) # add explicit cause because todo is state
(maintainGoal {@self conversation ?irrConv}).


rule goal-conv-ASK-bothAvail
{@self goal {@self ASK ?question ?audience}:?ask}: ?goal
{@self conversation @nothing}
{?audience conversation @nothing}
    ->
(o /hyp [k conversation] {@o participant @self} {@o participant ?audience}): ?irrConv
(maintainBelief {?irrConv todo ?ask /causes ?goal}) # add explicit cause because todo is state
(maintainGoal {@self conversation ?irrConv}).


# This rule handles the case where we want to ask something to someone we're currently speaking with
rule conv-ASK-todo
{@self goal {@self ASK ?question ?audience}:?ask}: ?goal
{@self conversation @something:?myConv}
{?audience conversation ?myConv}
    ->
(maintainBelief {?myConv todo ?ask /causes ?goal}). # add explicit cause because todo is state

# If you're wondering where the rule that proposes the ASK action is,
# it's in conversation.mc, which proposes any "todo", which the rule
# above sets up.

rule goal-ASK-outcome
{@self goal {@self ASK ?question ?audience}}: ?goal
{@self /past ASK ?question ?audience /causes ~?goal /out?}: ?ASK
    ->
(setOutcome ?goal (outcome ?ASK)).


*/