; ----------------------------------------------------------------------------
; converse ?talk - THE exchange @self holds in the conversation ?talk, one per conversation
; whoever is in it. Opening a conversation is hail (tasks/hail-task.mc), taking one up is take-up
; (tasks/take-up-task.mc); every driver that has a line for someone in ?talk proposes this same
; clause, so the reasons to be talking are its parents and it rides the keenest of them.
;
; @self faces whom he is talking to and answers what each party asks: "I don't know" when he does
; not know, and a refusal when the answer is closer than he holds the asker (withholds). A party
; who joins the conversation by hailing him is greeted back, caused by his opening. Below every
; line he owes, he says his next move to each party (next-move, funcs/conversation.mc): the
; errand question he has for him, his news, asking a friend's, gossip. He takes his leave
; (tasks/take-leave-task.mc) once nobody in the conversation has anything left to say, himself
; included (said-all). Every line is said through tell. It is over, a success, when he is no
; longer in ?talk; left alone in it, he leaves it, which releases it.
;
; The rungs run together by design: turning and looking hold the head while the lines take
; the mouth, one tell at a time.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

(task {@self converse ?talk}:?converse
  (tar @excl [k conversation] @object)
  (lint-waive try-rungs-not-exclusive)
  ; Ending with the conversation still open is being outcompeted: he takes his leave first, so
  ; the others know it is over. Begun, because the converse proposing it has ended.
  (lint-waive begin-proposal)
  (cease
    (if (and (in-conversation @self ?talk) (other-party-in ?talk))
        (then (begin-proposal {@self take-leave ?talk} /uninterruptable))))
  (and
    (try
      (lint-waive cacheable-read-in-when)
      (when (not (in-conversation @self ?talk)))
      (effects (set-outcome ?converse /succ)))
    (try
      (lint-waive cacheable-read-in-when)
      (when (and (in-conversation @self ?talk) (not (other-party-in ?talk))))
      (effects
        (leave-conversation)
        (set-outcome ?converse /succ)))

    (try
      (lint-waive cacheable-read-in-when)
      (bind (focus-of ?talk) ?focus)
      (when (substantial ?focus))
      (effects (maintain-proposal {@self LOOK-AT ?focus})))
    (try
      (lint-waive cacheable-read-in-when)
      (bind (focus-of ?talk) ?focus)
      (when (and (substantial ?focus) (not (is-facing ?focus))))
      (effects (maintain-proposal {@self TURN-TO ?focus})))

    (try
      (role ?speaker {?talk participant ?speaker}
                   {?speaker SAY ? @self /past}:?said
                   (happened-since ?said ?converse)
        (when (said-all ?talk))
        (effects (maintain-proposal {@self take-leave ?talk}))))

    (try
      (lock)
      (role ?joiner {?joiner SAY ? @self /past}
                   {?joiner SAY (formulaic ? opening-phrase ?..) @self /past}:?opening
                   -{@self tell ? ?joiner /succ /caused_by ?opening}
                   -{@self take-up ?joiner /succ /caused_by ?opening}
                   -{@self turn-down ?joiner ? /succ /caused_by ?opening}
        (when (in-conversation ?joiner ?talk))
        (effects
          (bind (hail-response ?opening) ?response)
          (maintain-proposal {@self tell ?response ?joiner} /caused_by ?opening /quit-trying-on-fail))))

    (try
      (lock)
      (role ?asker {?asker SAY ? @self /past}
                   {?asker SAY (qs ? ? ?..):?qs @self /past}:?asked
                   -{@self tell ? ?asker /succ /caused_by ?asked}
        (when (and (in-conversation ?asker ?talk) (withholds ?qs ?asker)))
        (effects (maintain-proposal {@self tell (formulaic [] refusal answer) ?asker} /caused_by ?asked /quit-trying-on-fail))))
    (try
      (lock)
      (role ?questioner {?questioner SAY ? @self /past}
                   {?questioner SAY (qs ? ? ?..):?qs @self /past}:?asked
                   -{@self tell ? ?questioner /succ /caused_by ?asked}
        (when (and (in-conversation ?questioner ?talk) (not (withholds ?qs ?questioner))))
        (effects
          (bind (answer-to ?qs ?questioner) ?answer)
          (maintain-proposal {@self tell ?answer ?questioner} /caused_by ?asked /quit-trying-on-fail))))

    (try
      (role ?listener {?talk participant ?listener}
        (bind (next-move ?talk ?listener) ?move)
        (when (and (neq ?listener @self) (in-conversation ?listener ?talk) (substantial ?move)
                   (none {@self tell ?move ?listener /succ})))
        (effects (maintain-proposal {@self tell ?move ?listener} /quit-trying-on-fail))))))
