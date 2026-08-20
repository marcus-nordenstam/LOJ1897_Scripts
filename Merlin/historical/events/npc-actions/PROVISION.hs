; ----------------------------------------------------------------------------
; provision (npc-action) - the counter stop of the provisioning errand
; (npc-think/provisioning_think.hs). Fires ONLY at the shop the cook KNOWS
; sells provisions. She grabs up to a basket (carry_cap), never more than the
; kitchen larder is short of its target. A laden hand is then a live pressure:
; provision_rearm mints the general bring goal that carries the food TO THE
; KITCHEN (the larder room), put down only when she stands in it (bring lane).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")
(include "../../macros/tunables.hs")
(include "../../macros/collection_macros.hs")

; A pure act: the BUY CAP (basket vs larder shortfall vs what is already in
; hand) is the proposing think's arithmetic and rides the pattern; the body
; only fills the basket at the shop it stands in - the physical grabbing.
(npc-action {@self PROVISION ?cap}
  (duration 15)
  (effects
    ; The shelf is ONE food pile; the basket is ONE food pile in hand. Buying
    ; is a pile-to-pile transfer: decrement the shelf, top up the basket - never
    ; more than one bread-loaf explicitly represented, shop to hand to home.
    (spatial @self building): ?shop
    (for-each ?room (spatial ?shop parts [k interior_space room] /env)
      (do
        (bind 0 ?shop_pile)
        (pile-at-into ?room [k food] ?shop_pile)
        (if (and ?shop_pile (> (attr ?shop_pile count) 0))
            (then
              (min ?cap (attr ?shop_pile count)): ?grab
              (pile-take ?shop_pile ?grab)
              (bind 0 ?hand_pile)
              (held-pile-into @self [k food] ?hand_pile)
              (if (not ?hand_pile)
                  (then (create-entity [k pile] (qual location ?room)): ?new_basket
                        (set-attr ?new_basket content_kind [k food])
                        (set-attr ?new_basket count 0)
                        (take-item ?new_basket)
                        (bind ?new_basket ?hand_pile)))
              (pile-add ?hand_pile ?grab)
              (begin-belief {@self provisions_shop ?shop})))))
    (set-outcome {@self PROVISION ?cap} succ)))
