
# We need a 'done' stack to put each item in when we are done viewing it
rule make-done-stack-propose
{@self stack_browse ?stack}
{?stack obb ?obb}
(none {?stack done_stack ?})
    ->
(maintain_proposal {@self make_done_stack ?stack ?obb}).


rule make-done-stack-action-propose
{@self make_done_stack ?workingStack ?doneStackObb}
(observed ?workingStack) # We need to have observed the ?stack in order to make a done-stack for it.
    ->
(maintain_proposal {@self MAKE_DONE_STACK ?workingStack ?doneStackObb}).
