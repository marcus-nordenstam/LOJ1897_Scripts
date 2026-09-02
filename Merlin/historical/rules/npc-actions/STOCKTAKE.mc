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
; grocer already bound his own premises via (spatial @self building) off his
; {@self job.org ?org}->{?org workplace ?wp} presence; the count-then-spawn
; is idempotent (a full shelf is a no-op), so only the day's shortfall (sold
; / stolen / eaten down) is re-seeded. Replaces world-act/grocer_restock.hs.
; ----------------------------------------------------------------------------

(include "../../macros/collection-macros.mc")

; The daily shelf cap - one town-day of provisions (a food prop is a
; person-day, so the shelf carries roughly the parish between restocks). The
; shelf is ONE food pile (Objects.mon `pile`): the count IS the stock, so a
; restock is a single top-up write, not ~200 entity spawns, and a co-present
; shopper sees one {pile count N} belief instead of 200 loaf beliefs.
(define-macro grocer_shelf_stock () 200)

; The weapons shelf cap. Any shop carries a small stock (a firearm + a knife) -
; the ONLY way a weapon reaches a home is BUYING or STEALING one off a shop
; shelf; nothing is pre-seeded into buildings. Firearms count by the FAMILY kind
; (any firearm), spawned as a canonical pistol; knives count/spawn as knife.
(define-macro shop_weapon_stock () 3)

; The stocktake round itself: the goal, at the counter, is the leaf and promotes
; here. The begun-then-ended {@self STOCKTAKE} act-belief IS the round (30 min).
(npc-action {@self STOCKTAKE}
  (track-skill-level [k accountancy])
  (duration 30)
  (effects
    (if (spatial @self building)
        (then
          (spatial @self building): ?shop
          (spatial ?shop parts [k interior-space room] /env): ?rooms
          ; Validate the shelves against belief - every room of the shop.
          (for-each ?room ?rooms
            (take-stock-of ?room [k food]))
          ; Re-seed the shopfront to the daily cap (the morning delivery): top
          ; the ONE food pile (/limit 1 room) back up to the cap. Idempotent -
          ; a full shelf writes the same count it already holds.
          (for-each ?room ?rooms /limit 1
            (do
              (bind 0 ?food_pile)
              (pile-at-into ?room [k food] ?food_pile)
              (if (not ?food_pile)
                  (then (create-entity [k pile] ?room): ?food_pile
                        (set-attr ?food_pile content-kind [k food])))
              (set-attr ?food_pile count (grocer_shelf_stock))))
          ; Restock the weapons + household-chemicals shelf the same way (one room
          ; carries the stock). Poison counts by the toxin FAMILY, spawns the
          ; household staple (white-arsenic) - just another provision the shop carries.
          (for-each ?room ?rooms /limit 1
            (repeat (- (shop_weapon_stock) (count (spatial ?room contents [k firearm] /env)))
              (create-entity [k pistol] ?room): ?gun)
            (repeat (- (shop_weapon_stock) (count (spatial ?room contents [k knife] /env)))
              (create-entity [k knife] ?room): ?blade)
            (repeat (- (shop_weapon_stock) (count (spatial ?room contents [k toxin] /env)))
              (create-entity [k white-arsenic] ?room): ?tox))))
    (set-outcome {@self STOCKTAKE} /succ)))
