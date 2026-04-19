
# We need a 'done' stack to put each item in when we are done viewing it
rule make-done-stack-propose
{@self stack_browse ?stack}
{?stack obb ?obb}
(none {?stack done_stack ?})
    ->
(maintainProposal {@self make_done_stack ?stack ?obb}).


rule make-done-stack-action-propose
{@self make_done_stack ?workingStack ?doneStackObb}
(observed ?workingStack) # We need to have observed the ?stack in order to make a done-stack for it.
    ->
(maintainProposal {@self MAKE_DONE_STACK ?workingStack ?doneStackObb}).
