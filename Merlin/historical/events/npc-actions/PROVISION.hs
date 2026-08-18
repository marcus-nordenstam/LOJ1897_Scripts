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

; A pure act: the BUY CAP (basket vs larder shortfall vs what is already in
; hand) is the proposing think's arithmetic and rides the pattern; the body
; only fills the basket at the shop it stands in - the physical grabbing.
(npc-action {@self PROVISION ?cap}
  (duration 15)
  (effects
    (building @self): ?shop
    (for-each ?room (spatial ?shop parts [k interior_space room] /env)
      (for-each ?item (spatial ?room contents [k food] /env) /limit ?cap
        (do
          (take-item ?item)
          (begin-belief {@self provisions_shop ?shop}))))
    (set-outcome {@self PROVISION ?cap} succ)))
