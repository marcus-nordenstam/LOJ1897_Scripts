; ----------------------------------------------------------------------------
; converse ?talk - @self's PRESENCE in the conversation ?talk, one per conversation whoever is in
; it: he faces whom he is talking to and stays. It says nothing: every dialogue-line is said by a
; dialogue task of its class (respond, inquire, catch-up ..), proposed by that class's own driver,
; and leaving is take-leave, which it proposes itself once said-all holds. Opening a
; conversation is hail, taking one up is take-up; every driver that brings @self to talk in ?talk
; proposes this same clause, so it rides the keenest of them.
;
; It is over, a success, when he is no longer in ?talk. Once nobody in it has anything left to say
; (said-all, funcs/conversation.mc) and something has been said to him in it, he takes his leave:
; the last to run out goes, and his goodbye wakes the rest. Walked out of call of everyone in it,
; he has left it, and goes without a word; left alone in it he leaves it
; (thinks/conversation-alone-think.mc).
; Outcompeted, he is not simply gone: his closing takes his leave saying what calls him away, and
; the act that outbid him starts once he has. Ending any other way still in it, he takes his leave
; the same way; already out of it, his closing has nothing to do.
; ----------------------------------------------------------------------------

(task {@self converse ?talk}:?converse
  (construed-act social-act)
  (category social)
  (hosts social reply)
  (tar @excl [k conversation] @object)
  (lint-waive try-rungs-not-exclusive)
  ; Ending still in the conversation, he takes his leave first, so the others know it is over.
  ; Begun, because the converse proposing it has ended.
  (lint-waive begin-proposal)
  (success-cond (not (in-conversation @self ?talk)))
  (cease
    (if (in-conversation @self ?talk)
        (then (begin-proposal {@self take-leave ?talk} /uninterruptable))))
  (closing
    (sequence
      (stage
        (bind (top-competing-act {@self converse ?talk} (utility ?converse)) ?called-by)
        (effects
          (cond
            (case (not (in-conversation @self ?talk)))
            (case (substantial ?called-by)
              (maintain-proposal {@self take-leave ?talk (formulaic [] leave_taking excuse ?called-by)}
                                 /uninterruptable))
            (else (maintain-proposal {@self take-leave ?talk} /uninterruptable)))))
      (stage
        (effects (done-closing ?converse)))))
  (and
    (try
      (lint-waive cacheable-read-in-when)
      (when (and (in-conversation @self ?talk) (out-of-call-of ?talk)))
      (effects (leave-conversation ?talk)))
    (try
      (lint-waive cacheable-read-in-when)
      (declare-utility fallback)
      (when (in-conversation @self ?talk))
      (effects (maintain-proposal {@self DWELL (spatial @self space) (+ (time hour) 1)})))
    (try
      (role @self (in-conversation @self ?talk) (other-party-in ?talk) (said-all ?talk)
        (role ?speaker {?talk participant ?speaker}
                       {?speaker SAY ? @self /past}:?said
          (when (happened-since ?said ?converse))
          (effects (maintain-proposal {@self take-leave ?talk} /uninterruptable)))))
    (try
      (lint-waive cacheable-read-in-when)
      (bind (focus-of ?talk) ?focus)
      (when (substantial ?focus))
      (effects (maintain-proposal {@self LOOK-AT ?focus})))
    (try
      (lint-waive cacheable-read-in-when)
      (bind (focus-of ?talk) ?focus)
      (when (and (substantial ?focus) (not (is-facing ?focus))))
      (effects (maintain-proposal {@self TURN-TO ?focus})))))
