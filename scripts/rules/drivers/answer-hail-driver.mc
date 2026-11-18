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
; The hail is the caller's opening to him, standing in the log of the talk he was called into with
; no reply of his (caller-in, funcs/talk.mc), at both levels of detail; of several callers in one
; talk he answers the one who called first. The answer waits to be said until the opening has been
; heard (take-up, turn-down).
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

; (turning-down ?speaker) - @self has begun turning down ?speaker's talk.
(define-func turning-down (?speaker)
  (substantial (any {@self turn-down ?speaker ?})))

(driver answer-hail-driver
  (role ?talk (bb-public-every ?talk participant @self)
    (and
      ; Engage: taking it up, at what talking with ?speaker is worth to him - task selection weighs
      ; it against whatever else he has going.
      (try
        (bind (caller-in ?talk) ?speaker)
        (bind (hail-utility ?speaker) ?utility)
        (declare-utility (utility-band ?utility) (utility-value ?utility))
        (when (and (substantial ?speaker) (eq (caller-in ?talk) ?speaker)
                   (within-call ?speaker)
                   (not (in-full-talk))
                   (not (rebuffs ?speaker))
                   (not (turning-down ?speaker))
                   (not (too-crowded-for ?speaker))))
        (effects
          (bind (any {? participant @self}) ?part)
          (if (substantial ?part)
              (then (maintain-proposal {@self take-up ?speaker} /caused_by ?part))
              (else (maintain-proposal {@self take-up ?speaker})))))
      ; A take-up he has begun is a yes already being said: he finishes it.
      (try
        (belief {@self take-up ?speaker}
          (when (unsubstantial (bb-public-read-rec ?speaker bbk-hail-answer @self answer)))
          (declare-utility unbeatable)
          (effects
            (bind (any {? participant @self}) ?part)
            (if (substantial ?part)
                (then (maintain-proposal {@self take-up ?speaker} /caused_by ?part))
                (else (maintain-proposal {@self take-up ?speaker}))))))
      ; Decline once task selection has put something else above taking it up (outbids), saying
      ; what it is: the decision is made once, and the refusal it begins always completes.
      (try
        (bind (caller-in ?talk) ?speaker)
        (bind (flip (substantial ?speaker) (outbids {@self take-up ?speaker}) @nothing) ?busy-with)
        (when (and (substantial ?speaker) (eq (caller-in ?talk) ?speaker)
                   (within-call ?speaker)
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
                                    /caused_by ?part))
              (else
                (bind (under-way ?busy-with) ?reason)
                (begin-proposal {@self turn-down ?speaker (formulaic [] refusal ?reason)} /uninterruptable)))))
      ; A man who has had his fill of company turns a hail down, saying so, unless it obliges him.
      (try
        (bind (caller-in ?talk) ?speaker)
        (when (and (substantial ?speaker) (eq (caller-in ?talk) ?speaker)
                   (within-call ?speaker)
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
                                    /caused_by ?part))
              (else (begin-proposal {@self turn-down ?speaker (formulaic [] refusal weary)} /uninterruptable)))))
      ; Rebuffing a man he despises: a retort, heard as the insult it is.
      (try
        (bind (caller-in ?talk) ?speaker)
        (when (and (substantial ?speaker) (eq (caller-in ?talk) ?speaker)
                   (within-call ?speaker)
                   (not (in-full-talk))
                   (rebuffs ?speaker)))
        (declare-utility unbeatable)
        (effects
          (bind (any {? participant @self}) ?part)
          (if (substantial ?part)
              (then (maintain-proposal {@self turn-down ?speaker (formulaic [] rebuff)}
                                       /caused_by ?part))
              (else (maintain-proposal {@self turn-down ?speaker (formulaic [] rebuff)}
                                      ))))))))
