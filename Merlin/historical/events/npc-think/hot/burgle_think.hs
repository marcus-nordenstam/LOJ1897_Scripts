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
  (burgle-target @self):?scene
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
  (current-building @self):?scene
  (when (and (or (at-burgle-residence)
                 (at-own-workplace))
             ?scene
             (owner-of ?scene)
             (owner-of ?scene): ?owner
             (alive ?owner)
             (not (= ?owner @self))))
  (utility 86)
  ; The LOOT is picked HERE (the first loose visible valuable - the walk is the
  ; same env truth (venue)/(burgle-target) read); an empty-handed scene still
  ; ledgers the intrusion, discharges and ends the goal (nothing to take).
  (effects
    (if (at-own-workplace) (then embezzle) (else opportunist_theft)): ?method
    (bind 0 ?found)
    (for-each ?room (attr-values ?scene parts [k interior_space room])
      (for-each ?item (attr-values ?room contents)
        (if (and (= ?found 0) (has-facet ?item valuable))
            (then (bind ?item ?loot) (bind 1 ?found)))))
    (if (= ?found 1)
        (then (maintain-proposal {@self take_item ?loot ?owner}))
        (else
          (begin-ended-belief {@self ?method ?owner})
          (begin-ended-belief {@self steal ?owner})
          (crime-ledger-append @self ?owner ?method steal @fail @fail)
          (burglary-confrontation @self ?scene)
          (caused-by ?sgoal {@self pressure ?}): ?p
          (discharge-pressure ?p 0.75)
          (end-goal {@self steal})))))

; Outcome twin: THIS pursuit's take concluded - the /succ record's own
; /caused_by names the gated goal, so a stale record from an earlier theft
; never concludes a fresh pursuit. The twin INTERPRETS the take as the theft:
; the method + steal anchors (born-ended act records - count-ever reads them),
; the ledger row with the loot kind, the residents' chance to stir, the
; grievance discharged (no-op on @fail for an appetitive steal), the goal ends.
(npc-think steal_done
  (goal {@self steal}:?sgoal)
  (role @self (believes {@self take_item ?loot ?owner /succ}:?rec))
  (when (caused-by ?rec ?sgoal))
  (effects
    (if (at-own-workplace) (then embezzle) (else opportunist_theft)): ?method
    (begin-ended-belief {@self ?method ?owner})
    (begin-ended-belief {@self steal ?owner})
    (crime-ledger-append @self ?owner ?method steal (kind ?loot) @fail)
    (if (current-building @self)
        (then (burglary-confrontation @self (current-building @self))))
    (caused-by ?sgoal {@self pressure ?}): ?p
    (discharge-pressure ?p 0.75)
    (end-goal {@self steal})))
