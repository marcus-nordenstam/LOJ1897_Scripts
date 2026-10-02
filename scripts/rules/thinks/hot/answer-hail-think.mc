; ----------------------------------------------------------------------------
; answer-hail (thinks). A hail - a (formulaic opening ..) said to @self - is ALWAYS answered,
; and how is @self's choice: engage, decline or rebuff (hail-answer, funcs/conversation.mc).
;
; weigh-hail makes that choice ONCE and writes it on the heard record. Weighed again while
; the answer is being said, the answer itself would be what he is busy with, and an
; engagement would turn into a refusal mid-word. Each answer rule says its answer, while
; ?speaker is within call, until he has finished saying something to ?speaker since the hail
; (hail-answered). The choice stays written on the hail, so an answered hail is never
; weighed again; the next hail from the same man is a record of its own.
; ----------------------------------------------------------------------------

(include "../../../macros/tunables.mc")

(think weigh-hail
  (role ?speaker {?speaker SAY ? @self /past}
                 {?speaker SAY (formulaic opening ?) @self /past}:?heard
                 (bb-none ?heard answer)
    (when (within-call ?speaker))
    (effects
      (bind (tolerate (top-motivator [k legs] [k mouth])) ?busy)
      (if (is-belief ?busy)
          (then (bb-write ?heard busy ?busy)))
      (bb-write ?heard answer (hail-answer ?speaker ?busy)))))

; The three answers read weigh-hail's choice off the hail record in their (when): the record is
; not the role's candidate, so only a live gate's read watches it - in the role, the write
; would wake nothing.

; Taking it up: a greeting back, and the conversation, at a utility that outbids whatever
; he sets aside for it (engage-utility).
(think engage-hail
  (lint-waive cacheable-read-in-when)
  (role ?speaker {?speaker SAY ? @self /past}
                 {?speaker SAY (formulaic opening ?) @self /past}:?heard
    (when (and (= (bb-read ?heard answer) engage)
               (within-call ?speaker)
               (not (hail-answered ?heard ?speaker))))
    (bind (nth 2 ?heard.target) ?greeting)
    (bind (engage-utility ?speaker (tolerate (bb-read ?heard busy))) ?worth)
    (declare-utility (utility-band ?worth) (utility-value ?worth))
    (effects
      (bb-public-maintain @self conversing ?speaker (conversing_ttl_cycles))
      (maintain-proposal {@self tell (formulaic response ?greeting) ?speaker} /caused_by ?heard)
      (if -{@self goal {@self converse ?speaker}}
          (then (begin-goal {@self converse ?speaker}))))))

; Declining for what he is doing. The refusal is part of that: caused by it, it rides its
; utility and is its descendant, so the chain it speaks for never outbids it.
(think decline-hail
  (lint-waive cacheable-read-in-when)
  (role ?speaker {?speaker SAY ? @self /past}
                 {?speaker SAY (formulaic opening ?) @self /past}:?heard
    (bind (tolerate (bb-read ?heard busy)) ?busy)
    (when (and (= (bb-read ?heard answer) decline)
               (within-call ?speaker)
               (not (hail-answered ?heard ?speaker))
               (substantial (utility ?busy))))
    (bind (utility ?busy) ?worth)
    (declare-utility (utility-band ?worth) (utility-value ?worth))
    (effects
      (maintain-proposal {@self tell (formulaic refusal busy) ?speaker} /caused_by ?busy))))

; Rebuffing a man he despises: a retort, heard as the insult it is.
(think rebuff-hail
  (lint-waive cacheable-read-in-when)
  (role ?speaker {?speaker SAY ? @self /past}
                 {?speaker SAY (formulaic opening ?) @self /past}:?heard
    (when (and (= (bb-read ?heard answer) rebuff)
               (within-call ?speaker)
               (not (hail-answered ?heard ?speaker))))
    (declare-utility want)
    (effects
      (maintain-proposal {@self tell (formulaic rebuff (msg-class insult)) ?speaker} /caused_by ?heard))))
