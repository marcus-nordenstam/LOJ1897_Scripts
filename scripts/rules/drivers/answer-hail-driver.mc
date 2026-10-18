; ----------------------------------------------------------------------------
; answer-hail (thinks). A hail - a (formulaic opening-phrase ..) said to @self by a man whose public
; (conversing ..) names him (funcs/conversation.mc) - is ALWAYS answered, and how is @self's
; choice: engage, decline or rebuff. Engaging is taking up the conversation
; (tasks/take-up-task.mc) and then holding the exchange (tasks/converse-task.mc) while it stays
; open; declining and rebuffing are turning it down (tasks/turn-down-task.mc). Whatever he answers
; he finishes: a turn-down and a begun take-up both run at (declare-utility unbeatable), above
; everything he has going. The choice stays open until he begins answering: a man who would have
; engaged but finds something keener before he has begun taking it up declines instead, and says
; what it is.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

; (turning-down ?speaker) - @self has begun turning down ?speaker's conversation.
(define-func turning-down (?speaker)
  (substantial (any {@self turn-down ?speaker ?})))

; Taking it up, at what talking with ?speaker is worth to him, while nothing else he has going
; outbids it; then the exchange, for as long as the conversation he took up is open.
(driver engage-hail
  (role ?speaker {?speaker SAY ? @self /past}
                 {?speaker SAY (formulaic ? opening-phrase ?) @self /past}
    (bind (hail-worth ?speaker) ?worth)
    (declare-utility (utility-band ?worth) (utility-value ?worth))
    (stable-or
      (try
        (when (and (invited-by ?speaker)
                   (within-call ?speaker)
                   (not (rebuffs ?speaker))
                   (not (turning-down ?speaker))
                   (unsubstantial (top-competing-act {@self take-up ?speaker} ?worth))))
        (effects (maintain-proposal {@self take-up ?speaker})))
      (try
        (when (and (conversing-with @self ?speaker)
                   (conversing-with ?speaker @self)
                   (took-up ?speaker)))
        (effects (maintain-proposal {@self converse ?speaker}))))))

; A take-up he has begun is a yes already being said: he finishes it.
(driver complete-take-up
  (role ?speaker {?speaker SAY ? @self /past}
                 {?speaker SAY (formulaic ? opening-phrase ?) @self /past}
    (when (and (invited-by ?speaker)
               (taking-up ?speaker)))
    (declare-utility unbeatable)
    (effects (maintain-proposal {@self take-up ?speaker}))))

; Declining for what he would rather be doing, and saying what it is: the decision is made once,
; and the refusal it begins always completes.
(driver decline-hail
  (role ?speaker {?speaker SAY ? @self /past}
                 {?speaker SAY (formulaic ? opening-phrase ?) @self /past}
    (bind (hail-worth ?speaker) ?worth)
    (when (and (invited-by ?speaker)
               (within-call ?speaker)
               (not (rebuffs ?speaker))
               (not (taking-up ?speaker))
               (not (turning-down ?speaker))
               (not (proposed {@self turn-down ? ?}))
               (substantial (top-competing-act {@self take-up ?speaker} ?worth))))
    (declare-utility unbeatable)
    (lock)
    (lint-waive begin-proposal)
    (effects
      (bind (top-competing-act {@self take-up ?speaker} ?worth) ?busy-with)
      (begin-proposal {@self turn-down ?speaker (formulaic [] refusal ?busy-with)} /uninterruptable))))

; Rebuffing a man he despises: a retort, heard as the insult it is.
(driver rebuff-hail
  (role ?speaker {?speaker SAY ? @self /past}
                 {?speaker SAY (formulaic ? opening-phrase ?) @self /past}
    (when (and (invited-by ?speaker)
               (within-call ?speaker)
               (rebuffs ?speaker)))
    (declare-utility unbeatable)
    (effects
      (maintain-proposal {@self turn-down ?speaker (formulaic [/msg-class insult] rebuff)}))))
