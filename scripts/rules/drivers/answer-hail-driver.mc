; ----------------------------------------------------------------------------
; answer-hail (driver). A hail - a (formulaic opening-phrase ..) said to @self to its end by a man
; in a talk (funcs/talk.mc) - is ALWAYS answered, and how is @self's
; choice: engage, decline or rebuff. Engaging is taking up the talk
; (tasks/take-up-task.mc), which gives him his part in it (drivers/stay-in-talk-driver.mc);
; declining and rebuffing are turning it down (tasks/turn-down-task.mc). Whatever he answers
; he finishes: a turn-down and a begun take-up both run at (declare-utility unbeatable), above
; everything he has going. The choice stays open until he begins answering: a man who would have
; engaged but finds something keener before he has begun taking it up declines instead, and says
; what it is. A man in a talk answers as a line of it: taking the
; caller up brings him into that talk, and turning him down is said over his shoulder and
; gives the talk as what he is busy with - neither ends it.
; The hail is the record of him on the board of the talk he was called in (bbk-hail,
; boards/talk.mc), at both levels of detail: he is cast on that talk and on the man its record names
; as his caller, and answers while it says called. A man he is calling himself he does not answer:
; each of two men who call each other has taken the other up (tasks/hail-task.mc).
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

; (turning-down ?speaker) - @self has begun turning down ?speaker's talk.
(define-func turning-down (?speaker)
  (substantial (any {@self turn-down ?speaker ?})))

; (busy-reason ?busy-with) - what @self gives as keeping him from a hail: the talk he holds a part
; in, else what he has under way, ?busy-with.
(define-func busy-reason (?busy-with)
  (cond (case (holds-part @self (talk-of @self)) in_talk)
        (else (under-way ?busy-with))))

(driver answer-hail-driver
  (role ?talk (bb-public-every ?talk bbk-hail @self)
    (role ?speaker (bb-public-read-rec ?talk bbk-hail @self caller)
      (when (called-in ?talk))
      (and
        ; Engage: taking it up, at what talking with ?speaker is worth to him - task selection weighs
        ; it against whatever else he has going.
        (try
          (bind (hail-utility ?speaker) ?utility)
          (declare-utility (utility-band ?utility) (utility-value ?utility))
          (when (and (not (calling ?speaker))
                     (within-call ?speaker)
                     (not (in-full-talk))
                     (not (rebuffs ?speaker))
                     (not (turning-down ?speaker))
                     (not (too-crowded-for ?speaker))))
          (effects
            (maintain-proposal {@self take-up ?speaker})))
        ; A take-up he has begun is a yes already being said: he finishes it.
        (try
          (belief {@self take-up ?speaker}
            (declare-utility unbeatable)
            (effects
              (maintain-proposal {@self take-up ?speaker}))))
        ; Decline once task selection has put something else above taking it up (outbids), saying
        ; what it is: the decision is made once, and the refusal it begins always completes.
        (try
          (bind (outbids {@self take-up ?speaker}) ?busy-with)
          (when (and (not (calling ?speaker))
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
            (bind (busy-reason ?busy-with) ?reason)
            (begin-proposal {@self turn-down ?speaker (formulaic [] refusal ?reason)} /uninterruptable)))
        ; A man who has had his fill of company turns a hail down, saying so, unless it obliges him.
        (try
          (when (and (not (calling ?speaker))
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
            (begin-proposal {@self turn-down ?speaker (formulaic [] refusal weary)} /uninterruptable)))
        ; Rebuffing a man he despises: a retort, heard as the insult it is.
        (try
          (when (and (not (calling ?speaker))
                     (within-call ?speaker)
                     (not (in-full-talk))
                     (rebuffs ?speaker)))
          (declare-utility unbeatable)
          (effects
            (maintain-proposal {@self turn-down ?speaker (formulaic [] rebuff)})))))))
