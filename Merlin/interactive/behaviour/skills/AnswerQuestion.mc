
# Questions are always modeled as FUNCTIONS phrased so that their output always produces the appropriate ANSWER.
#
# Question-functions may return a truthful or distored answer, by giving the /distort qualifier.
# Distoring the answer is how we implement lying.
#
# NOTE that the polarity of the question does NOT matter.
#
# For example, regardless if someone asks you "do you like shoes?" or "don't you like shoes?", 
# if your answer is "no", they will believe that you DONT like shoes in both cases.
#
# However, beliefs are always stored in the positive, regardless of the polarity of the source or 
# cause of the belief.




# "do you know who this is?" - respond with relationship + name
rule answer-question-respond-to-do-you-know-this
{!@self:?person /ever ASK (qs /do_you_know /this (any {/b ?entity /ever name}).target):?question @self}: ?person_asked
(none {@self /succ TELL ? ?person /causes ~?person_asked})
(lock_rule answer_question 1) # higher priority than the general answer-question below
    ->
(any {?entity /ever name}).target: ?name
(any {@self /ever ? ?entity}).label: ?relation
(if (eq ?name @unknown)
    (maintain_goal {@self TELL (formulaic no_dont_know) ?person} (des abs_util 1))
    (maintain_goal {@self TELL (formulaic yes_this_is ?relation ?name) ?person} (des abs_util 1))): ?response
# If we are currently expecting a question from ?person, quit expecting it
#(any {@self expect_question ?person}): ?expect_question
#(end_belief ?expect_question)
# Since the person asking is not an act performed by myself,
# we have to explicitly add it as a cause for my response.
#(add_causes ?response ?person_asked ?expect_question)
(add_causes ?response ?person_asked)
(forget_on_cease).



rule answer-question-respond-general
{!@self:?person /ever ASK ?question @self}: ?person_asked
(none {@self /succ TELL ? ?person /causes ~?person_asked})
(lock_rule answer_question 0) # general answer-question rule
    ->
# Evaluate the question to produce an answer
(eval_msg /output_unknown_on_fail ?question): ?truthfulAnswer
# Set an absolute utility of 1, signifying that answering a question is higher priority than posing a question
(maintain_goal {@self TELL (msg ?truthfulAnswer) ?person} (des abs_util 1)): ?response
# If we are currently expecting a question from ?person, quit expecting it
#(any {@self expect_question ?person}): ?expect_question
#(end_belief ?expect_question)
# Since the person asking is not an act performed by myself,
# we have to explicitly add it as a cause for my response.
#(add_causes ?response ?person_asked ?expect_question)
(add_causes ?response ?person_asked)
# Most rules declare at least one task among its conditions, which results in the rule not activating without
# said task-condition.  This rule, however, does *not* list any task since talking isn't something
# that requires a task.  So, to avoid a build-up of activated (but no longer firing) instances of this rule, 
# we use (forget_on_cease) to make sure the rule forgotten as soon as it ceases to fire.
(forget_on_cease).


# If someone asks a person if they want to do something, infer that someone wants the person to do it.
# For example if someone asks "do you want to go for a walk?", one would assume they want you to go for a walk.
rule answer-question-infer-desire-from-question
{!@self:?someone /ever ASK (qs (prob {?person goal {?person /task ? ?}:?task})) ?person}: ?question
    ->
(begin_belief {?someone goal ?task /sources ?question})
# As with the other rule above, this rule doesn't list a running task or goal in its header, so we manually 
# get rid of it once it has fired.
(fire_and_forget).


# wanting:
#   communicative - asking if someone wants, telling that I want
#   reasoning - knowing what I want, and be able to answer questions about what I want


/* 
{?person ASK ?question @me}: ?personAsk
(none {@i SAY ? ?person /causes ~?personAsk})
    ->
(e ?question): ?truth
(e /distort ?question): ?lie
(util ?person learn ?truth): ?truthUtil
(util ?person learn ?lie): ?lieUtil
(if (ge ?truthUtil ?lieUtil)
    (maintain_goal {@i TELL ?truth ?person /causes ~?personAsk})
    (maintain_goal {@i TELL ?lie ?person /causes ~?personAsk})).
*/