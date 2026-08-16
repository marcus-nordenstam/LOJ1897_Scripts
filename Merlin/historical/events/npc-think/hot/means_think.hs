; ----------------------------------------------------------------------------
; means - the npc-THINK half: the DESIRE that arms a weapon-gated killer.
; A killer holding a method_means it does not yet control pushes utility onto the
; standing {@self acquire [k <means>]} goal so it promotes to acquire_act.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")
(include "../../../macros/possession_macros.hs")

; The DESIRE: a killer who holds a method_means it does not yet control resolves to
; obtain it. Binds the required tool kind off its own belief and pushes utility 90
; onto the standing {@self acquire [k <means>]} goal (the killer's memory of setting
; out to arm), which - the leaf - promotes to acquire_act. A maintenance event: it
; ceases (ends the acquire goal) the moment the killer controls the tool
; (real-possession termination), the falling edge of (not (control ?means)). NO (log) here - this
; fires in the deliberation pass; the acquisition is narrated at completion.
(npc-think means_plan_acquire
  (role @self (believes {@self method_means ?means}))    ; binds the required tool kind, cached
  (when (not (control ?means)))
  (utility errand 900)
  (effects       (begin-goal {@self acquire ?means}))
  (cease-effects (end-goal   {@self acquire ?means})))

; THE ERRAND - obtaining is a real trip, never conjuring: shops are the only item
; source (STOCKTAKE stocks every shop with weapons + chemicals), so the killer walks
; to a shop and takes the tool off the shelf ("buying" carries no cash yet; taking
; someone else's stock reads as theft in a later pass). Guarded by the kill still
; standing so the errand withdraws if the intent dies.

; not at a shop yet -> head to one (any shop carries the stock).
(npc-think acquire_go
  (goal {@self acquire ?means})
  (when (and (is-kind ?means)
             (not (control ?means))
             (has-goal {@self kill})
             (find-building [k building shop]): ?shop
             (not (in-building @self ?shop))))
  (utility 900)
  (effects (maintain-proposal {@self enter ?shop})))

; at a shop: find a shelf item of the means kind and take it (the burgle_strike
; loot-walk shape: env-truth room + content sweep, first hit is the pick).
(npc-think acquire_take
  (goal {@self acquire ?means})
  (when (and (is-kind ?means)
             (not (control ?means))
             (has-goal {@self kill})
             (is-a (building @self) [k building shop])))
  (utility 900)
  (effects
    (building @self): ?shop
    (bind 0 ?found)
    (for-each ?room (env-parts ?shop [k interior_space room])
      (for-each ?item (env-content ?room ?means) /limit 1
        (if (= ?found 0)
            (then (bind ?item ?loot) (bind 1 ?found)))))
    (if (= ?found 1)
        (then (maintain-proposal {@self take ?loot})))))
