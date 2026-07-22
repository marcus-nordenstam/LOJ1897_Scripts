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
  (schedule on-commit)
  (if-blocked hold)
  (goal {@self steal})
  (rng-stream theft)
  ; Bind the scene at the EVENT level (not inside (effects)) so ?scene is in scope for
  ; BOTH (effects) and (cease-effects) - a fire-time stash restores it at cease.
  (bind (burgle-target @self) ?scene)
  (when (and (not (at-burgle-residence))
             (not (at-own-workplace))))
  (utility 85)
  (effects
    (begin-goal {@self steal})
    (if ?scene
        (then (begin-goal {@self enter ?scene}))))
  (cease-effects
    (if ?scene
        (then (end-goal {@self enter ?scene})))))

; TERMINAL step (act_body_purification): AT a strikeable scene the theft is now PROPOSED (was a
; self-affirming re-begin that used to auto-promote). Utility 86 outbids the travel rung (85) by a
; point, so arrival flips routing into the strike. One terminal for both scenes; steal_act's completion
; picks the crime method (embezzle at the thief's own workplace, else opportunist_theft). Reactive:
; re-proposes each decision point while standing at the scene.
(npc-think burgle_strike
  (schedule always)
  (goal {@self steal})
  (when (or (at-burgle-residence)
            (at-own-workplace)))
  (utility 86)
  (effects (propose {@self steal})))
