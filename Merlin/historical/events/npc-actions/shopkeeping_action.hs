; ----------------------------------------------------------------------------
; shopkeeping (npc-action) - the stocktake round + the morning re-stock.
;
; The clerk, at his counter with the standing stocktake goal, walks the
; premises for half an hour validating what he believes is on the shelves
; against what actually is (take-stock-of, stocktake_macros.hs): a
; sold / stolen / eaten item's whereabouts belief ends at the gap where it
; used to sit. Utility 82: a shade over the work shift (80), so the round
; happens on arrival and the counter work resumes after. The per-cycle desire
; (stocktake_round) lives in npc-think/shopkeeping.hs.
;
; RE-STOCK: restocking the shelves is the grocer's OWN daily job, done at
; his OWN co-present shop - the deliveries a Victorian shop takes each
; morning. It folds into the SAME stocktake completion (same grocer, same
; shop, same day): after validating the shelves he tops the shopfront back
; up to the daily cap. No world scan of the incorporation register - the
; grocer already bound his own premises via (current-building @self) off his
; {@self job.org ?org}->{?org workplace ?wp} presence; the count-then-spawn
; is idempotent (a full shelf is a no-op), so only the day's shortfall (sold
; / stolen / eaten down) is re-seeded. Replaces world-act/grocer_restock.hs.
; ----------------------------------------------------------------------------

; The daily shelf cap - one town-day of provisions (a food prop is a
; person-day, so the shelf carries roughly the parish between restocks).
; Matches the founding-time seed (k_grocer_food_stock=200). Stocked into a
; SINGLE room (/limit 1 below): 200 sits well under the 256 `contents`
; plural cap even with the shopfront's furnishings + household-chemical
; shelf, so - unlike the old whole-shop total spread round-robin across
; rooms purely to dodge that cap - one room needs no round-robin, and the
; whole-shop total stays ~200 (the validated food-economy tuning) instead
; of 200-per-room.
(define-macro grocer_shelf_stock () 200)

; The stocktake round itself: the goal, at the counter, is the leaf and promotes
; here. The begun-then-ended {@self stocktake} act-belief IS the round (30 min).
(npc-action {@self stocktake}
  (duration 30)
  (effects
    (bind (current-building @self) ?shop)
    (if (is-entity ?shop)
        (then
          ; Validate the shelves against belief - every room of the shop.
          (for-each ?room (attr-values ?shop parts [k interior_space room])
            (take-stock-of ?room [k food]))
          ; Re-seed the shopfront to the daily cap (the morning delivery).
          ; ONE room carries the whole town-day (/limit 1); the shortfall is
          ; (cap - what is already there), so a full shelf spawns nothing.
          (for-each ?room (attr-values ?shop parts [k interior_space room]) /limit 1
            (repeat (- (grocer_shelf_stock) (count-entities [k food] ?room))
              (create-entity [k food] (qual location ?room) (bind ?item))))))
    (set-outcome {@self stocktake} succ)))
