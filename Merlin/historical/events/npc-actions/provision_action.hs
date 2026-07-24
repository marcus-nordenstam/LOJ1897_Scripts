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

; A pure act (act_body_purification): the "at a shop" precondition moved to the
; provision_at_shop guarded (maintain-proposal) - provision is a proposed label, so it promotes
; ONLY at a shop the cook has routed to (provision_go walks only to the known
; provisions_shop). The current shop is re-derived from (current-building @self) below.
(npc-action {@self provision}
  (duration 15)
  (effects
    (bind (current-building @self) ?shop)
    (bind {@self household_cook ?home})
    ; The KITCHEN is the mind's OWN mental kitchen object (the home-rooms
    ; pre-teach mints {home room <r>}); it bounds the buy to the larder's
    ; shortfall - the SAME object want_provisions counts and provision_rearm
    ; targets when it re-drives the bring goal from a laden hand.
    (bind {?home room [k kitchen]:?kitchen})
    (if (is-entity ?kitchen)
        (then
          (bind (count-believed-located [k food] ?kitchen) ?blv)
          (bind (count-controlled @self [k food]) ?inh)
          (for-each ?room (attr-values ?shop parts [k interior_space room])
            (for-each ?item (attr-values ?room contents [k food])
                      /limit (- (min (carry_cap) (- (larder_target) ?blv)) ?inh)
              (do
                (take-item ?item)
                (begin-belief {@self provisions_shop ?shop}))))))
    (set-outcome {@self provision} succ)))
