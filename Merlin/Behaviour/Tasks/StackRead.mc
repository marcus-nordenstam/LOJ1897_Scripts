

# Reading docs in a stack relies on the "stack_browse" activity 
# that makes us get docs from the stack, one at a time.
rule stack-read-browse-proposal
{@self stack_read ?stack}
{?stack isa [k object stack]}
    ->
(maintainProposal {@self stack_browse ?stack}).


# If we are viewing a doc but have not read it, then read it
rule stack-read-read-viewed-doc-proposal
{@self stack_read ?stack}: ?stack_read
{@self stack_browse ?stack /causes ~?stack_read}
# I have NOT read the doc I am currently viewing
{@self view ?doc}
    ->
# then try to read it
(maintainProposal {@self read ?doc}).


# If we are still viewing a doc that we have read, 
# put it into the 'done' stack.  
# (The stack_browse activity creates this stack for us).
rule stack-read-put-done-doc-proposal
{@self stack_read ?stack}: ?stack_read
{@self stack_browse ?stack /causes ~?stack_read}
# There is a stack where I can put the docs I am done with
{?stack done_stack ?done_stack}
# I have read the doc I am currently viewing
{@self view ?doc}
{@self /succ read ?doc}
    ->
# then try to dispose of it
(maintainProposal {@self stack_put ?doc ?done_stack}).


# If the stack is empty, end the activity /succ
rule stack-read-outcome-empty-succ
{@self stack_read ?stack}: ?stack_read
{?stack isa [k object stack]}
{?stack top @nothing}
(none {@self view ?})
    ->
(setOutcome ?stack_read /succ).


rule stack-read-cleanup-read-doc-to-done-stack
{?doc from_stack ?stack}
{?stack done_stack ?done_stack}
{?hand control ?doc}
{@self hand ?hand}
{@self /ever /succ READ ?doc}
(none {@self stack_read ?stack})
    ->
(maintainProposal {@self stack_put ?doc ?done_stack}).


rule stack-read-cleanup-unread-doc-to-source-stack
{?doc from_stack ?stack}
{?hand control ?doc}
{@self hand ?hand}
(none {@self /ever /succ READ ?doc})
(none {@self stack_read ?stack})
    ->
(maintainProposal {@self stack_put ?doc ?stack}).
