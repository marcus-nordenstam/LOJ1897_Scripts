; ----------------------------------------------------------------------------
; answer-hail (thinks). A hail - a (formulaic opening-phrase ..) said to @self by a man in a
; conversation (funcs/conversation.mc) - is ALWAYS answered, and how is @self's
; choice: engage, decline or rebuff. Engaging is taking up the conversation
; (tasks/take-up-task.mc) and then holding the exchange (tasks/converse-task.mc) while it stays
; open; declining and rebuffing are turning it down (tasks/turn-down-task.mc). Whatever he answers
; he finishes: a turn-down and a begun take-up both run at (declare-utility unbeatable), above
; everything he has going. The choice stays open until he begins answering: a man who would have
; engaged but finds something keener before he has begun taking it up declines instead, and says
; what it is. A man in a conversation answers as a line of it, caused by his converse: taking the
; caller up brings him into that conversation, and turning him down is said over his shoulder and
; gives the conversation as what he is busy with - neither ends it.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

; (turning-down ?speaker) - @self has begun turning down ?speaker's conversation.
(define-func turning-down (?speaker)
  (substantial (any {@self turn-down ?speaker ?})))

; Taking it up, at what talking with ?speaker is worth to him, while nothing else he has going
; outbids it. Every answer to a hail is caused by the opening it answers.
(driver engage-hail-driver
  (role ?speaker {?speaker SAY ? @self /past}
                 {?speaker SAY (formulaic ? opening-phrase ?..) @self /past}:?opening
                 -{@self take-up ?speaker /succ /caused_by ?opening}
                 -{@self turn-down ?speaker ? /succ /caused_by ?opening}
                 (not (conversing-with @self ?speaker))
    (bind (hail-worth ?speaker) ?worth)
    (declare-utility (utility-band ?worth) (utility-value ?worth))
    (when (and (invited-by ?speaker)
               (within-call ?speaker)
               (not (rebuffs ?speaker))
               (not (turning-down ?speaker))
               (unsubstantial (top-competing-act {@self take-up ?speaker} ?worth))))
    (effects
      (bind (any {@self converse ?}) ?converse)
      (if (substantial ?converse)
          (then (maintain-proposal {@self take-up ?speaker} /caused_by ~[?opening ?converse]))
          (else (maintain-proposal {@self take-up ?speaker} /caused_by ?opening))))))

; A take-up he has begun is a yes already being said: he finishes it.
(driver complete-take-up-driver
  (role ?speaker {?speaker SAY ? @self /past}
                 {?speaker SAY (formulaic ? opening-phrase ?..) @self /past}:?opening
                 -{@self take-up ?speaker /succ /caused_by ?opening}
                 -{@self turn-down ?speaker ? /succ /caused_by ?opening}
                 (not (conversing-with @self ?speaker))
    (when (and (invited-by ?speaker)
               (taking-up ?speaker)))
    (declare-utility unbeatable)
    (effects
      (bind (any {@self converse ?}) ?converse)
      (if (substantial ?converse)
          (then (maintain-proposal {@self take-up ?speaker} /caused_by ~[?opening ?converse]))
          (else (maintain-proposal {@self take-up ?speaker} /caused_by ?opening))))))

; Declining for what he would rather be doing, and saying what it is: the decision is made once,
; and the refusal it begins always completes.
(driver decline-hail-driver
  (role ?speaker {?speaker SAY ? @self /past}
                 {?speaker SAY (formulaic ? opening-phrase ?..) @self /past}:?opening
                 -{@self take-up ?speaker /succ /caused_by ?opening}
                 -{@self turn-down ?speaker ? /succ /caused_by ?opening}
                 (not (conversing-with @self ?speaker))
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
      (bind (any {@self converse ?}) ?converse)
      (if (substantial ?converse)
          (then (begin-proposal {@self turn-down ?speaker (formulaic [] refusal ?converse)} /uninterruptable
                                /caused_by ~[?opening ?converse]))
          (else
            (bind (top-competing-act {@self take-up ?speaker} ?worth) ?busy-with)
            (begin-proposal {@self turn-down ?speaker (formulaic [] refusal ?busy-with)} /uninterruptable
                            /caused_by ?opening))))))

; Rebuffing a man he despises: a retort, heard as the insult it is.
(driver rebuff-hail-driver
  (role ?speaker {?speaker SAY ? @self /past}
                 {?speaker SAY (formulaic ? opening-phrase ?..) @self /past}:?opening
                 -{@self take-up ?speaker /succ /caused_by ?opening}
                 -{@self turn-down ?speaker ? /succ /caused_by ?opening}
                 (not (conversing-with @self ?speaker))
    (when (and (invited-by ?speaker)
               (within-call ?speaker)
               (rebuffs ?speaker)))
    (declare-utility unbeatable)
    (effects
      (bind (any {@self converse ?}) ?converse)
      (if (substantial ?converse)
          (then (maintain-proposal {@self turn-down ?speaker (formulaic [/msg-class insult] rebuff)}
                                   /caused_by ~[?opening ?converse]))
          (else (maintain-proposal {@self turn-down ?speaker (formulaic [/msg-class insult] rebuff)}
                                   /caused_by ?opening))))))
