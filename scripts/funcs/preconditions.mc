; ----------------------------------------------------------------------------
; The preconditions an act may (requires ..), each declared once with the act that fills it. A
; proposal of an act whose precondition does not hold proposes the fill in its stead, and the act
; once the fill has succeeded.
; ----------------------------------------------------------------------------

; He knows where ?x is: a box for it, seen or remembered, or the space it is in. A spot or a kind is
; nowhere to find.
(precondition placed (?x)
  (holds (flip (is-object ?x)
               (or (substantial (tolerate (spatial ?x bounds)))
                   (substantial (tolerate (spatial ?x space))))
               @true))
  (fulfil
    (cond (case (is-a ?x [k human])
                (maintain-proposal {@self find-person ?x}))
          (case (or (is-a ?x [k building]) (is-a ?x [k unit]))
                (maintain-proposal {@self find-building ?x (current-exterior @self)}))
          (case (is-a ?x [k space])
                (maintain-proposal {@self find-room ?x (place-holding ?x)}))
          (else (maintain-proposal {@self find-thing ?x})))))

; He stands inside ?place, a building or a unit.
(precondition inside (?place)
  (holds (within-place @self ?place))
  (fulfil (maintain-proposal {@self enter-building ?place})))

; He knows a room of kind ?kind in ?place, a building or a unit. A building kind is no such question.
(precondition knows-room-of (?kind ?place)
  (holds (flip (is-object ?place) (known-room-of ?kind ?place) @true))
  (fulfil (maintain-proposal {@self find-room ?kind ?place})))

; He knows a building of kind ?kind. Anything but a kind is no such question.
(precondition knows-building-of (?kind)
  (holds (flip (is-kind ?kind) (substantial (find-building-found ?kind)) @true))
  (fulfil (maintain-proposal {@self find-building ?kind (current-exterior @self)})))
