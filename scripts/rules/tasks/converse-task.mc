; ----------------------------------------------------------------------------
; converse ?talk - @self's PRESENCE in the conversation ?talk, one per conversation whoever is in
; it: he faces whom he is talking to and stays. It says nothing: every dialogue-line is said by a
; dialogue task of its class (answer, inquire, friend-talk ..), proposed by that class's own driver,
; and leaving is take-leave, which it proposes itself once said-all holds. Opening a
; conversation is hail, taking one up is take-up; every driver that brings @self to talk in ?talk
; proposes this same clause, so it rides the keenest of them.
;
; It is over, a success, when he is no longer in ?talk. Once nobody in it has anything left to say
; (said-all, funcs/conversation.mc) and something has been said to him in it, he takes his leave:
; the last to run out goes, and his goodbye wakes the rest. Left alone in it, he leaves it, which
; releases it. Outcompeted, he is not simply gone: his closing rung says what calls him away and
; leaves the talk, and the act that outbid him starts once he has.
; ----------------------------------------------------------------------------

(task {@self converse ?talk}:?converse
  (tar @excl [k conversation] @object)
  (lint-waive try-rungs-not-exclusive)
  ; Ending still in the conversation with others in it, he takes his leave first, so they know it
  ; is over; alone in it, he leaves it. Begun, because the converse proposing it has ended.
  (lint-waive begin-proposal)
  (cease
    (if (in-conversation @self ?talk)
        (then
          (if (other-party-in ?talk)
              (then (begin-proposal {@self take-leave ?talk} /uninterruptable))
              (else (leave-conversation))))))
  (closing
    (sequence
      (stage
        (bind (top-competing-act {@self converse ?talk} (utility ?converse)) ?called-by)
        (effects
          (if (substantial ?called-by)
              (then (maintain-proposal {@self tell (formulaic [] leave_taking excuse ?called-by) ?talk}
                                       /uninterruptable))
              (else (maintain-proposal {@self tell (formulaic [] leave_taking bye) ?talk} /uninterruptable)))))
      (stage
        (effects
          (leave-conversation)
          (done-closing ?converse)))))
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
      (role ?speaker {?talk participant ?speaker}
                     {?speaker SAY ? @self /past}:?said
        (when (and (in-conversation @self ?talk)
                   (other-party-in ?talk)
                   (happened-since ?said ?converse)
                   (said-all ?talk)))
        (effects (maintain-proposal {@self take-leave ?talk} /uninterruptable))))
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
