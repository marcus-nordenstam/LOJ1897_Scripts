

# Pay attention to the (initial) stack level (so we know if its empty or not)
# NOTE that the '?stack top' event is updated by the STACK_TAKE and STACK_PUT actions
# so we only ever have to explicitly observe it at the start of the activity, hence this rule.
rule stack-browse-perceive-top-proposal
{@self stack_browse ?stack}: ?browseStack
    ->
(maintainProposal {@self perceive_attr ?stack top}).


# We can't start this activity if we're already gripping objects because we don't want to confuse those
# with the objects from the stack that we will be browsing.  So just drop any objects we're holding.
rule stack-browse-drop-unrelated-things-proposal
{@self stack_browse ?stack}: ?stack_browse
{@self hand ?hand}
# Any objects taken from the stack will have the 'from_stack' state on them
# (because STACK_TAKE adds that state)
(o /known {?hand control @o} {@o /not from_stack ?stack}): ?thing
    ->
(maintainProposal {@self drop ?thing}).


# This rule prevents us from greedily getting multiple docs at a time.
rule stack-browse-get-next-doc-proposal
{@self stack_browse ?stack}
# the stack is NOT empty
{?stack top @something:?doc}
# and I am NOT gripping anything
{@self hand ?hand}
{?hand control @nothing}
    ->
# then set a goal to get the next doc from the stack
(maintainProposal {@self stack_get ?doc ?stack}).



