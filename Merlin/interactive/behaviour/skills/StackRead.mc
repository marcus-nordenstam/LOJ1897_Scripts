

# Reading docs in a stack relies on the "stack_browse" activity 
# that makes us get docs from the stack, one at a time.
rule stack-read-browse-proposal
{@self stack_read ?stack}
{?stack isa [k object stack]}
    ->
(maintain_proposal {@self stack_browse ?stack}).


# If we are viewing a doc but have not read it, then read it
rule stack-read-read-viewed-doc-proposal
{@self stack_read ?stack}: ?stack_read
{@self stack_browse ?stack /causes ~?stack_read}
# I have NOT read the doc I am currently viewing
{@self view ?doc}
    ->
# then try to read it
(maintain_proposal {@self read ?doc}).


# If we are still viewing a doc that we have read, 
# put it into the 'done' stack.  
# (The stack_browse activity creates this stack for us).
rule stack-read-put-done-doc-proposal
{@self stack_read ?stack}: ?stack_read
{@self stack_browse ?stack /causes ~?stack_read}
# I have read the doc I am currently viewing
{@self view ?doc}
{@self /succ read ?doc}
# There is a 'done' stack where I can put the docs I am finished with
# (the working stack's done-stack is recorded on the private blackboard).
(bb_private_read ?stack done_stack): ?done_stack
    ->
# then try to dispose of it
(maintain_proposal {@self stack_put ?doc ?done_stack}).


# If the stack is empty, end the activity /succ
rule stack-read-outcome-empty-succ
{@self stack_read ?stack}: ?stack_read
{?stack isa [k object stack]}
{?stack top _}
(none {@self view ?})
    ->
(set_outcome ?stack_read /succ).


rule stack-read-cleanup-read-doc-to-done-stack
{@self hand ?hand}
{?hand control ?doc}
{@self /ever /succ READ ?doc}
# ?doc's source stack and that stack's done-stack are private-bb entries.
(bb_private_read ?doc from_stack): ?stack
(bb_private_read ?stack done_stack): ?done_stack
(none {@self stack_read ?stack})
    ->
(maintain_proposal {@self stack_put ?doc ?done_stack}).


rule stack-read-cleanup-unread-doc-to-source-stack
{@self hand ?hand}
{?hand control ?doc}
(bb_private_read ?doc from_stack): ?stack
(none {@self /ever /succ READ ?doc})
(none {@self stack_read ?stack})
    ->
(maintain_proposal {@self stack_put ?doc ?stack}).
