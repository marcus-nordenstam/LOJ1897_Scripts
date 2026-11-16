; ----------------------------------------------------------------------------
; obligation-respond - a line said to @self that calls for an answer obliges him to respond to it
; (tasks/respond-task.mc), owed to its speaker: its class (line-kind) carries answer-owed, owed
; wherever it is said to him (a question, a flirt), or answer-owed-in-talk, owed when its speaker is
; in the talk he is in (ontology/concepts.mon), presented only: unpresented, with no decorum, only the
; answer-owed are owed, and stay owed until answered. In a talk a speaker's last line is
; the one answered, so a new line of his discharges what his earlier ones were owed, bar the one he is
; already saying his reply to; out of one only
; a question or a flirt stays owed until answered. Responding discharges it, and so does taking a
; part in another talk since the line was said in-talk. The obligation stands, or a
; superseded one ends, as the line is heard (immediate), and minting it wakes the driver that
; reads it.
; ----------------------------------------------------------------------------

(reflex {?speaker SAY ? @self /ever}:?SAY
  (immediate)
  (lint-waive lod-in-condition)
  (line-kind ?SAY):?kind
  (when (and (neq ?speaker @self)
             (or (has-facet ?kind answer-owed)
                 (and (has-facet ?kind answer-owed-in-talk) (presented-lod) (in-one-talk @self ?speaker)))))
  (effects (begin-belief {@self obligation {@self respond ?speaker ?SAY} ?speaker /caused_by ?SAY})))

(reflex {? SAY ? @self /ever}:?SAY
  (immediate)
  (lint-waive reflex-duplicate-pattern lod-in-condition)
  (role ?speaker {@self obligation {@self respond ?speaker ?line} ?speaker}:?owed
                 (eq ?speaker ?SAY.subject)
                 (neq ?line ?SAY)
                 (not (saying-reply-to ?line))
                 (or (and (presented-lod) (in-one-talk @self ?speaker)) (not (has-facet (line-kind ?line) answer-owed)))
    (effects (end-belief ?owed))))

(reflex {@self respond ?speaker ?line /succ}
  (when {@self obligation {@self respond ?speaker ?line} ?speaker})
  (effects (end-belief {@self obligation {@self respond ?speaker ?line} ?speaker})))

(reflex {?talk participant @self}:?part
  (role ?speaker {@self obligation {@self respond ?speaker ?line} ?speaker}:?owed
    (when (and (not (has-facet (line-kind ?line) answer-owed)) (not (happened-since ?line ?part))))
    (effects (end-belief ?owed))))
