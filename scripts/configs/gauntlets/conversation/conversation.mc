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
