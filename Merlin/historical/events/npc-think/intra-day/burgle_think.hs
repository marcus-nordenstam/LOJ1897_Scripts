; ----------------------------------------------------------------------------
; burgle (think lane) - the go/strike think rungs of the theft errand chain. The
; theft act + the at-burgle-residence / at-own-workplace macros live in
; npc-act/burgle.hs (loaded first, so these rungs may use those macros).
;
;   burgle_go      : hold the steal goal -> pick an occupied non-home same-town
;                    residence ((burgle-target), env-truth like (venue)) and
;                    travel there. No scene qualifies -> no act (try again at a
;                    later deliberation).
;   burgle_strike  : standing in a residence that is not my own with the goal
;                    -> the short theft act. Outbids burgle_go by one point, so
;                    arrival flips travel into the strike.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; APPROACH - hold the steal goal but not yet at a strikeable scene: pick an
; occupied non-home same-town residence ((burgle-target), env-truth) and travel
; there. Pushes the steal utility so the go sub-goal it maintains promotes; steal
; is a non-leaf while {@self go ?scene} stands. No scene qualifies -> nothing.
(npc-think burgle_go
  (short-term-think)
  (goal {@self steal})
  (rng-stream theft)
  (when (and (not (at-burgle-residence))
             (not (at-own-workplace))))
  (utility 85)
  (cont-fire-effects
    (begin-goal {@self steal})
    (bind (burgle-target @self) ?scene)
    (if ?scene
        (go-into ?scene))))

; AT a strikeable scene: push the steal utility so {@self steal}, now the leaf,
; promotes to steal_act. One desire for both scenes; steal_act's completion picks
; the crime method (embezzle at the thief's own workplace, else opportunist_theft).
(npc-think burgle_strike
  (short-term-think)
  (goal {@self steal})
  (when (or (at-burgle-residence)
            (at-own-workplace)))
  (utility 86)
  (cont-fire-effects (begin-goal {@self steal})))
