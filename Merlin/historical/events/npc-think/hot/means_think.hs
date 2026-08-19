; ----------------------------------------------------------------------------
; means - the npc-THINK half: the DESIRE that arms a shooter.
; A killer running the shoot task who holds no firearm pushes utility onto a standing
; {@self acquire [k firearm]} goal so it promotes to the shop errand.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; The DESIRE: a shooter running the shoot task who holds no firearm resolves to obtain
; one. It pushes utility onto a standing {@self acquire [k firearm]} goal (the killer's
; memory of setting out to arm), which promotes to the shop errand below. A maintenance
; event: it ceases (ends the acquire goal) the moment the killer controls a firearm, the
; falling edge of the empty-grip test. NO (log) here - the acquisition narrates at completion.
(npc-think shoot_arm
  (task {@self shoot ?})
  (role @self )
  (when (empty (spatial @self hold [k firearm])))
  (utility errand always-pick)
  (effects       (begin-goal {@self acquire [k firearm]}))
  (cease-effects (end-goal   {@self acquire [k firearm]})))

; THE ERRAND - obtaining is a real trip, never conjuring: shops are the only item
; source (STOCKTAKE stocks every shop with weapons + chemicals), so the killer walks
; to a shop and takes the tool off the shelf ("buying" carries no cash yet; taking
; someone else's stock reads as theft in a later pass). Guarded by the kill still
; standing so the errand withdraws if the intent dies.

; not at a shop yet -> head to one (any shop carries the stock).
(npc-think acquire_go
  (goal {@self acquire ?means})
  (when (and (is-kind ?means)
             (empty (spatial @self hold ?means))
             (has-goal {@self kill})
             (find-building [k building shop]): ?shop
             (not (in-building @self ?shop))))
  (effects (maintain-proposal {@self enter ?shop})))

; at a shop: find a shelf item of the means kind and take it (the burgle_strike
; loot-walk shape: env-truth room + content sweep, first hit is the pick).
(npc-think acquire_take
  (goal {@self acquire ?means})
  (when (and (is-kind ?means)
             (empty (spatial @self hold ?means))
             (has-goal {@self kill})
             (is-a (building @self) [k building shop])))
  (effects
    (building @self): ?shop
    (bind 0 ?found)
    (for-each ?room (spatial ?shop parts [k interior_space room] /env)
      (for-each ?item (spatial ?room contents ?means /env) /limit 1
        (if (= ?found 0)
            (then (bind ?item ?loot) (bind 1 ?found)))))
    (if (= ?found 1)
        (then (maintain-proposal {@self take ?loot})))))
