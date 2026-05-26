
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


rule compute-answer
{!@self:?person /ever ASK ?question @self}: ?person_asked
(bb_private_none ?question answer)
(none {@self /succ TELL ? ?person /causes ~?person_asked})
(eval_msg /output_unknown_on_fail ?question): ?answer
    ->
(bb_private_write ?question answer ?answer).



# "do you know who this is?" - respond with relationship + name
rule tell-answer-do-you-know-this
{!@self:?person /ever ASK (qs /do_you_know /this (any {/b ?entity /ever name}).target):?question @self}: ?person_asked
(bb_private_read ?question answer): ?answer
(none {@self /succ TELL ? ?person /causes ~?person_asked})
(lock_rule tell_answer 1) # higher priority than the general answer-question below
    ->
(any {@self /ever ? ?entity}).label: ?relation
(if (eq ?answer @unknown)
    (maintain_goal {@self TELL (formulaic no_dont_know) ?person} (des abs_util 1))
    (maintain_goal {@self TELL (formulaic yes_this_is ?relation ?answer) ?person} (des abs_util 1))): ?response
# ?person_asked isn't a self-act so its causal link must be added explicitly
(add_causes ?response ?person_asked)
# No task among conditions - forget the activation once it ceases to keep the
# activated set from accumulating
(forget_on_cease).


rule tell-answer
{!@self:?person /ever ASK ?question @self}: ?person_asked
(bb_private_read ?question answer): ?answer
(none {@self /succ TELL ? ?person /causes ~?person_asked})
(lock_rule tell_answer 0) # defer to higher-priority specialized rules above
    ->
# abs_util 1 prioritises answering over posing your own questions.
# utterable_msg's 2nd arg (?person) derives the speech-act register descriptor
# toward the listener so it rides the wire on the (msg ...) - plan Phase 2.
(maintain_goal {@self TELL (utterable_msg ?answer ?person) ?person} (des abs_util 1)): ?response
# ?person_asked isn't a self-act so its causal link must be added explicitly
(add_causes ?response ?person_asked)
# Done answering this question
(bb_private_clear ?question answer)
# No task among conditions - forget the activation once it ceases to keep the
# activated set from accumulating
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