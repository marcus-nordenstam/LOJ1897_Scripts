; ----------------------------------------------------------------------------
; decorum (classifier). Manners and propriety as the 0..1 {@self decorum} float
; the repute fold and the life_aim role-gate read - the politeness aspect carried
; onto the dimension scale. (decorum-fold) in dimensions.hs carries the encoding.
;
; A value dim, not a band: a plain float self-belief (@excl - a re-assert
; replaces), not a mint-band. Monthly cooldown to match its sibling dims.
;
; The disgraced-nuclear-family taint the old C++ fold applied is NOT here: it
; needs a family-and-repute join no single (every ..) expresses, and it closes a
; decorum -> repute -> decorum cycle. Both need a ruling before it is authored.
; ----------------------------------------------------------------------------

(npc-think classify_decorum
  (cooldown 1 m)
  (rng-stream behaviour)

  (role @self {@self class_situation ?})

  (effects
    (begin-belief {@self decorum (decorum-fold @self)})))
