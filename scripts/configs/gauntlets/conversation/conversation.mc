; The conversation gauntlets' shared funcs, included by one config per case (c01-pair.mc,
; c02-three.mc ..). Seeds state only; nothing here behaves.

; The first residential building that holds a unit, as its unit: a chapel is a residential
; building too, and has none.
(define-func conversation-first-home ()
  (bind @nothing ?home)
  (for-each ?house (env-entities [k residential-building])
    (head (spatial ?house parts [k unit] /env)): ?unit
    (if (substantial ?unit) (then (bind ?unit ?home) (break))))
  (check (substantial ?home))
  ?home)

; (spoken-over) - in a mind: the lines two different men said to @self at once, each pair counted
; from both of its lines. A jump-clock line lasts exactly one second, so two that overlap end in
; the same second.
(define-func spoken-over ()
  (bind 0 ?pairs)
  (bind (every {? SAY ? @self /past}) ?lines)
  (for-each ?first-line ?lines
    (bind ?first-line.subject ?first-speaker)
    (bind (elapsed /seconds ?first-line) ?first-end)
    (for-each ?second-line ?lines
      (bind ?second-line.subject ?second-speaker)
      (bind (elapsed /seconds ?second-line) ?second-end)
      (if (and (neq ?first-speaker ?second-speaker) (= ?first-end ?second-end))
          (then (bind (+ ?pairs 1) ?pairs)))))
  ?pairs)
