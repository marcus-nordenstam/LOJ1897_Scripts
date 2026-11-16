; ----------------------------------------------------------------------------
; obligation-respond - the end of an obligation to respond to a line (tasks/respond-task.mc). It is
; begun when the line comes due (owe-reply, funcs/talk.mc): as it is heard, or once what blocked it
; is said. Responding discharges it and marks the line's reply given, and so does taking a part in
; another talk since a line owed only in-talk was said.
; ----------------------------------------------------------------------------

(reflex {@self respond ?speaker ?line /succ}
  (when {@self obligation {@self respond ?speaker ?line} ?speaker})
  (effects
    (end-belief {@self obligation {@self respond ?speaker ?line} ?speaker})
    (mark-reply-given ?line)))

(reflex {?talk participant @self}:?part
  (role ?speaker {@self obligation {@self respond ?speaker ?line} ?speaker}:?owed
    (when (and (not (has-facet (line-kind ?line) answer-owed)) (not (happened-since ?line ?part))))
    (effects (end-belief ?owed))))
