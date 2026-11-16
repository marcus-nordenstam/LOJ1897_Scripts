; ----------------------------------------------------------------------------
; answer-hail (driver). A hail - a (formulaic opening-phrase ..) said to @self by a man in a
; talk (funcs/talk.mc) - is ALWAYS answered, and how is @self's
; choice: engage, decline or rebuff. Engaging is taking up the talk
; (tasks/take-up-task.mc), which gives him his part in it (drivers/stay-in-talk-driver.mc);
; declining and rebuffing are turning it down (tasks/turn-down-task.mc). Whatever he answers
; he finishes: a turn-down and a begun take-up both run at (declare-utility unbeatable), above
; everything he has going. The choice stays open until he begins answering: a man who would have
; engaged but finds something keener before he has begun taking it up declines instead, and says
; what it is. A man in a talk answers as a line of it, caused by his part in it: taking the
; caller up brings him into that talk, and turning him down is said over his shoulder and
; gives the talk as what he is busy with - neither ends it.
; Every answer is caused by the opening it answers, and only a speaker's latest opening is
; answered: his hail stands on that one, unanswered while no take-up or turn-down of it succeeded.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

; (turning-down ?speaker) - @self has begun turning down ?speaker's talk.
(define-func turning-down (?speaker)
  (substantial (any {@self turn-down ?speaker ?})))

(driver answer-hail-driver
  (lod presented)
  (role ?speaker (bb-public-every ?speaker hailing @self)
                 {?speaker SAY (formulaic ? opening-phrase ?..) @self /past /most_recent}:?opening
                 -{@self take-up ?speaker /succ /caused_by ?opening}
                 -{@self turn-down ?speaker ? /succ /caused_by ?opening}
                 (not (in-one-talk @self ?speaker))
    (and
      ; Engage: taking it up, at what talking with ?speaker is worth to him - task selection weighs
      ; it against whatever else he has going.
      (try
        (bind (hail-utility ?speaker) ?utility)
        (declare-utility (utility-band ?utility) (utility-value ?utility))
        (when (and (within-call ?speaker)
                   (not (in-full-talk))
                   (not (rebuffs ?speaker))
                   (not (turning-down ?speaker))
                   (not (too-crowded-for ?speaker))))
        (effects
          (bind (any {? participant @self}) ?part)
          (if (substantial ?part)
              (then (maintain-proposal {@self take-up ?speaker} /caused_by ~[?opening ?part]))
              (else (maintain-proposal {@self take-up ?speaker} /caused_by ?opening)))))
      ; A take-up he has begun is a yes already being said: he finishes it.
      (try
        (belief {@self take-up ?speaker}
          (declare-utility unbeatable)
          (effects
            (bind (any {? participant @self}) ?part)
            (if (substantial ?part)
                (then (maintain-proposal {@self take-up ?speaker} /caused_by ~[?opening ?part]))
                (else (maintain-proposal {@self take-up ?speaker} /caused_by ?opening))))))
      ; Decline once task selection has put something else above taking it up (outbids), saying
      ; what it is: the decision is made once, and the refusal it begins always completes.
      (try
        (bind (outbids {@self take-up ?speaker}) ?busy-with)
        (when (and (within-call ?speaker)
                   (not (in-full-talk))
                   (not (rebuffs ?speaker))
                   (not (taking-up ?speaker))
                   (not (turning-down ?speaker))
                   (not (proposed {@self turn-down ? ?}))
                   (not (too-crowded-for ?speaker))
                   (substantial ?busy-with)))
        (declare-utility unbeatable)
        (lock)
        (lint-waive begin-proposal)
        (effects
          (bind (any {? participant @self}) ?part)
          (if (substantial ?part)
              (then (begin-proposal {@self turn-down ?speaker (formulaic [] refusal in_talk)} /uninterruptable
                                    /caused_by ~[?opening ?part]))
              (else
                (bind (under-way ?busy-with) ?reason)
                (begin-proposal {@self turn-down ?speaker (formulaic [] refusal ?reason)} /uninterruptable
                                /caused_by ?opening)))))
      ; A man who has had his fill of company turns a hail down, saying so, unless it obliges him.
      (try
        (when (and (within-call ?speaker)
                   (not (in-full-talk))
                   (not (rebuffs ?speaker))
                   (not (taking-up ?speaker))
                   (not (turning-down ?speaker))
                   (not (proposed {@self turn-down ? ?}))
                   (too-crowded-for ?speaker)))
        (declare-utility unbeatable)
        (lock)
        (lint-waive begin-proposal)
        (effects
          (bind (any {? participant @self}) ?part)
          (if (substantial ?part)
              (then (begin-proposal {@self turn-down ?speaker (formulaic [] refusal weary)} /uninterruptable
                                    /caused_by ~[?opening ?part]))
              (else (begin-proposal {@self turn-down ?speaker (formulaic [] refusal weary)} /uninterruptable
                                    /caused_by ?opening)))))
      ; Rebuffing a man he despises: a retort, heard as the insult it is.
      (try
        (when (and (within-call ?speaker)
                   (not (in-full-talk))
                   (rebuffs ?speaker)))
        (declare-utility unbeatable)
        (effects
          (bind (any {? participant @self}) ?part)
          (if (substantial ?part)
              (then (maintain-proposal {@self turn-down ?speaker (formulaic [] rebuff)}
                                       /caused_by ~[?opening ?part]))
              (else (maintain-proposal {@self turn-down ?speaker (formulaic [] rebuff)}
                                       /caused_by ?opening))))))))
