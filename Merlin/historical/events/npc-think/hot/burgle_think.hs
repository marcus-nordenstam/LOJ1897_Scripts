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

; The two STRIKEABLE scenes for the steal goal: an occupied residence that is not
; the thief's own home (a break-in), or the thief's OWN workplace (embezzlement -
; authorized presence). burgle_go heads to a residence when at neither; at either,
; the steal goal is the leaf and promotes to steal_action.
(define-macro at-burgle-residence ()
  (and (not (at-home))
       (is-a (building @self) [k building residential_building])))
; believes (not bind) so the effect-position call site below treats a jobless
; miss as plain false, never an effects abort.
(define-macro at-own-workplace ()
  (and (believes {@self job.org ?emp})
       (believes {?emp workplace ?work})
       (in-building @self ?work)))

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
  (utility want)
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
  (building @self):?scene
  (when (and (or (at-burgle-residence)
                 (at-own-workplace))
             ?scene
             (owner-of ?scene)
             (owner-of ?scene): ?owner
             (alive ?owner)
             (not (= ?owner @self))))
  ; The LOOT is picked HERE (the first loose visible valuable - the walk is the
  ; same env truth (venue)/(burgle-target) read); an empty-handed scene still
  ; ledgers the intrusion, discharges and ends the goal (nothing to take).
  (effects
    (if (at-own-workplace) (then embezzle) (else opportunist_theft)): ?method
    (bind 0 ?found)
    (for-each ?room (spatial ?scene parts [k interior_space room] /env)
      (for-each ?item (env-content ?room)
        (if (and (= ?found 0) (has-facet ?item valuable))
            (then (bind ?item ?loot) (bind 1 ?found)))))
    (if (= ?found 1)
        (then (maintain-proposal {@self take ?loot}))
        (else
          (begin-ended-belief {@self ?method ?owner})
          (begin-ended-belief {@self steal ?owner})
          (crime-ledger-append @self ?owner ?method steal @u @u)
          (burglary-confrontation @self ?scene)
          (caused-by ?sgoal {@self pressure ?}): ?p
          (discharge-pressure ?p 0.75)
          (end-goal {@self steal})))))

; Outcome twin: THIS pursuit's take concluded - the /succ record's own /caused_by
; names the gated goal, so a stale record from an earlier theft never concludes a
; fresh pursuit. steal_done just CONCLUDES the burglary: the residents get their
; chance to stir, the grievance is discharged, the goal ends. Interpreting the take
; AS a theft (the wronged owner, the method, the ledger row) is a separate concern -
; classify_take_as_theft below - keyed on OWNERSHIP of the scene, not on the taking.
(npc-think steal_done
  (goal {@self steal}:?sgoal)
  (role @self (believes {@self take ? /succ}:?rec))
  (when (caused-by ?rec ?sgoal))
  (effects
    (if (building @self)
        (then (burglary-confrontation @self (building @self))))
    (caused-by ?sgoal {@self pressure ?}): ?p
    (discharge-pressure ?p 0.75)
    (end-goal {@self steal})))

; Classify a completed take AS THEFT - but ONLY when @self does not own the premises
; it took from (a break-in residence, or the org whose workplace it embezzles). The
; wronged party is the scene's deed owner (owner-of ?scene); an ownerless / self-owned
; / dead-owner scene is no theft (the take still concludes via steal_done, nothing is
; recorded). Taking is just taking - the method + the {@self steal ?owner} anchor +
; the ledger row live HERE, off the scene's ownership, never off the take itself.
(npc-think classify_take_as_theft
  (goal {@self steal}:?sgoal)
  (role @self (believes {@self take ?loot /succ}:?rec))
  (when (and (caused-by ?rec ?sgoal)
             (building @self): ?scene
             (owner-of ?scene): ?owner
             (alive ?owner)
             (not (= ?owner @self))))
  (effects
    (if (at-own-workplace) (then embezzle) (else opportunist_theft)): ?method
    (begin-ended-belief {@self ?method ?owner})
    (begin-ended-belief {@self steal ?owner})
    (crime-ledger-append @self ?owner ?method steal (kind ?loot) @u)))
