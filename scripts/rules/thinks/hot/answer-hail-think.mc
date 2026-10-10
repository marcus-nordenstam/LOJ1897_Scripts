; ----------------------------------------------------------------------------
; answer-hail (thinks). A hail - a (formulaic opening ..) said to @self by a man whose public
; (conversing ..) names him (funcs/conversation.mc) - is ALWAYS answered, and how is @self's
; choice: engage, decline or rebuff. Engaging is taking up the conversation
; (tasks/take-up-task.mc) and then holding the exchange (tasks/converse-task.mc) while it stays
; open; declining and rebuffing are turning it down (tasks/turn-down-task.mc), at
; (unbeatable-utility ..), above everything he has going, so nothing can silence it. The choice
; stays open while he is invited and has not begun turning it down: a man who would have
; engaged but finds something keener before he has answered declines instead.
; ----------------------------------------------------------------------------

(include "../../../macros/tunables.mc")

; (turning-down ?speaker) - @self has begun turning down ?speaker's conversation.
(define-func turning-down (?speaker)
  (substantial (any {@self turn-down ?speaker ?})))

; Taking it up, at what talking with ?speaker is worth to him, while that beats everything
; else he has going; then the exchange, for as long as the conversation he took up is open.
(driver engage-hail
  (role ?speaker {?speaker SAY ? @self /past}
                 {?speaker SAY (formulaic ? opening ?) @self /past}
    (bind (hail-worth ?speaker) ?worth)
    (declare-utility (utility-band ?worth) (utility-value ?worth))
    (stable-or
      (try
        (when (and (invited-by ?speaker)
                   (within-call ?speaker)
                   (not (rebuffs ?speaker))
                   (not (turning-down ?speaker))
                   (would-engage ?speaker)))
        (effects (maintain-proposal {@self take-up ?speaker})))
      (try
        (when (and (conversing-with @self ?speaker)
                   (conversing-with ?speaker @self)
                   (took-up ?speaker)))
        (effects (maintain-proposal {@self converse ?speaker}))))))

; Declining for what he would rather be doing.
(driver decline-hail
  (role ?speaker {?speaker SAY ? @self /past}
                 {?speaker SAY (formulaic ? opening ?) @self /past}
    (when (and (invited-by ?speaker)
               (within-call ?speaker)
               (not (rebuffs ?speaker))
               (or (turning-down ?speaker) (not (would-engage ?speaker)))))
    (bind (unbeatable-utility {@self turn-down ?speaker (formulaic [] refusal busy)}) ?say)
    (declare-utility (utility-band ?say) (utility-value ?say))
    (effects
      (maintain-proposal {@self turn-down ?speaker (formulaic [] refusal busy)}))))

; Rebuffing a man he despises: a retort, heard as the insult it is.
(driver rebuff-hail
  (role ?speaker {?speaker SAY ? @self /past}
                 {?speaker SAY (formulaic ? opening ?) @self /past}
    (when (and (invited-by ?speaker)
               (within-call ?speaker)
               (rebuffs ?speaker)))
    (bind (unbeatable-utility {@self turn-down ?speaker (formulaic [/msg-class insult] rebuff)}) ?say)
    (declare-utility (utility-band ?say) (utility-value ?say))
    (effects
      (maintain-proposal {@self turn-down ?speaker (formulaic [/msg-class insult] rebuff)}))))
