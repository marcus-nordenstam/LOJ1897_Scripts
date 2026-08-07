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
        (then (maintain-proposal {@self enter ?scene})))))

; TERMINAL step (act_body_purification): AT a strikeable scene the theft is PROPOSED (a proposed
; label drops out of goal competition, so it does not auto-promote). Utility 86 outbids the travel
; rung (85) by a point, so arrival flips routing into the strike. One terminal for both scenes;
; steal_act's completion picks the crime method (embezzle at the thief's own workplace, else
; opportunist_theft).
(npc-think burgle_strike
  (goal {@self steal}:?sgoal)
  ; The wronged party is resolved and vetted HERE (whose premises this is =
  ; village-public knowledge): an ownerless / self-owned / dead-owner scene
  ; never strikes. The action receives ?owner off its own pattern and does no
  ; reasoning of its own.
  (bind (current-building @self) ?scene)
  (when (and (or (at-burgle-residence)
                 (at-own-workplace))
             (is-entity ?scene)
             (is-entity (owner-of ?scene))
             (bind (owner-of ?scene) ?owner)
             (alive ?owner)
             (not (= ?owner @self))))
  (utility 86)
  (effects (maintain-proposal {@self steal ?owner})))

; Outcome twin: THIS pursuit's theft concluded - the /succ record's own
; /caused_by names the gated goal, so a stale record from an earlier theft
; never concludes a fresh pursuit. Discharge the driving grievance (absent for
; an appetitive steal - discharge no-ops on @fail) and end the goal.
(npc-think steal_done
  (goal {@self steal}:?sgoal)
  (role @self (believes {@self steal ? /succ}:?rec))
  (when (caused-by ?rec ?sgoal))
  (effects
    (bind (caused-by ?sgoal {@self pressure ?}) ?p)
    (discharge-pressure ?p 0.75)
    (end-goal {@self steal})))
