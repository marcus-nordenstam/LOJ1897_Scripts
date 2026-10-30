; ----------------------------------------------------------------------------
; The preconditions a task may name in its (preconditions ..) - what must hold for it to start - or
; its (running-requirements ..) - what must hold to start and go on holding while it runs - each
; declared once with the act that achieves it. A task proposed while one does not hold is proposed
; as that achieve instead, and itself once the achieve has succeeded; a running requirement that
; stops holding withdraws the running task for its achieve the same way.
; ----------------------------------------------------------------------------

; He knows where ?x is: a box for it, seen or remembered, or the space it is in. A spot or a kind is
; nowhere to find.
(precondition placed (?x)
  (condition (flip (is-object ?x)
               (or (substantial (tolerate (spatial ?x bounds)))
                   (substantial (tolerate (spatial ?x space))))
               @true))
  (achieve
    (cond (case (is-a ?x [k human])
                (maintain-proposal {@self find-person ?x}))
          (case (or (is-a ?x [k building]) (is-a ?x [k unit]))
                (maintain-proposal {@self find-building ?x (current-exterior @self)}))
          (case (is-a ?x [k space])
                (maintain-proposal {@self find-room ?x (place-holding ?x)}))
          (else (maintain-proposal {@self find-thing ?x})))))

; He stands inside ?place, a building or a unit.
(precondition inside (?place)
  (condition (within-place @self ?place))
  (achieve (maintain-proposal {@self enter-building ?place})))

; He knows a room of kind ?kind in ?place, a building or a unit. A building kind is no such question.
(precondition knows-room-of (?kind ?place)
  (condition (flip (is-object ?place) (known-room-of ?kind ?place) @true))
  (achieve (maintain-proposal {@self find-room ?kind ?place})))

; He stands in a room of kind ?kind in ?bldg, a building or a unit, or in a building of the kind ?bldg.
(precondition stands-in-room-of (?kind ?bldg)
  (condition (and (stands-in-room ?kind)
              (flip (is-kind ?bldg) (stands-in-building ?bldg) (within-place @self ?bldg))))
  (achieve (maintain-proposal {@self enter-room-kind ?kind ?bldg})))

; He knows a building of kind ?kind. Anything but a kind is no such question.
(precondition knows-building-of (?kind)
  (condition (flip (is-kind ?kind) (substantial (find-building-found ?kind)) @true))
  (achieve (maintain-proposal {@self find-building ?kind (current-exterior @self)})))
