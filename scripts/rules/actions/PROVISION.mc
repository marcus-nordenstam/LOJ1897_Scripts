; ----------------------------------------------------------------------------
; provision (action) - the counter stop of the provisioning errand
; (thinks/provisioning_think.mc). Fires ONLY at the shop the cook KNOWS
; sells provisions. She grabs up to a basket (carry_cap), never more than the
; kitchen larder is short of its target. A laden hand is then a live pressure:
; provision-rearm mints the general bring goal that carries the food TO THE
; KITCHEN (the larder room), put down only when she stands in it (bring chain).
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")
(include "../../macros/collection-macros.mc")

; A pure act: the BUY CAP (basket vs larder shortfall vs what is already in
; hand) is the proposing think's arithmetic and rides the pattern; the body
; only fills the basket at the shop it stands in - the physical grabbing.
(action {@self PROVISION ?cap}:?PROVISION
  (motor body legs)
  (duration (seconds 15 min))
  (effects
    ; The shelf is ONE food pile; the basket is ONE food pile in hand. Buying
    ; is a pile-to-pile transfer: decrement the shelf, top up the basket - never
    ; more than one bread-loaf explicitly represented, shop to hand to home.
    (spatial @self building): ?shop
    (for-each ?room (spatial ?shop rooms /env)
      (do
        (bind 0 ?shop_pile)
        (for-each ?pile_cand (spatial ?room contents [k pile] /env)
          (if (attr-is ?pile_cand content-kind [k food])
              (then (bind ?pile_cand ?shop_pile))))
        (if (and ?shop_pile (> (attr ?shop_pile count) 0))
            (then
              (min ?cap (attr ?shop_pile count)): ?grab
              (set-attr ?shop_pile count (max 0 (- (attr ?shop_pile count) ?grab)))
              (bind 0 ?hand_pile)
              (for-each ?held_cand (spatial @self hold [k pile] /env)
                (if (attr-is ?held_cand content-kind [k food])
                    (then (bind ?held_cand ?hand_pile))))
              (if (not ?hand_pile)
                  (then (create-entity [k pile] ?room): ?new_basket
                        (set-attr ?new_basket content-kind [k food])
                        (set-attr ?new_basket count 0)
                        (spatial-write ?new_basket gripped-by (spatial @self left-hand) /env)
                        (bind ?new_basket ?hand_pile)))
              (set-attr ?hand_pile count (+ (attr ?hand_pile count) ?grab))
              (begin-belief {@self provisions-shop ?shop})))))
    (set-outcome ?PROVISION /succ)))
