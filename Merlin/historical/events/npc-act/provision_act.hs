; ----------------------------------------------------------------------------
; provision (npc-act) - the counter stop of the provisioning errand
; (npc-think/provisioning_think.hs). Fires ONLY at the shop the cook KNOWS
; sells provisions. She grabs up to a basket (carry_cap), never more than the
; kitchen larder is short of its target, then mints the general bring goal:
; the food goes TO THE KITCHEN (the larder room), put down only when she
; stands in it (bring lane).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")
(include "../../macros/tunables.hs")

; A pure act (act_body_purification): the "at a shop" precondition moved to the
; provision_at_shop guarded (propose) - provision is a proposed label, so it promotes
; ONLY at a shop the cook has routed to (provision_go walks only to the known
; provisions_shop). The current shop is re-derived from (current-building @self) below.
(npc-act provision_act
  (act {@self provision})
  (duration 15)
  (act-effects
    (bind (current-building @self) ?shop)
    (bind {@self household_cook ?home})
    ; The KITCHEN is the mind's OWN mental kitchen object (the home-rooms
    ; pre-teach mints {home room <r>}), so the bring goal minted here targets
    ; the SAME object want_provisions counts and provision_rearm re-drives.
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
                (begin-belief {@self provisions_shop ?shop}))))
          (begin-goal {@self bring [k food] ?kitchen})))
    (end-act {@self provision})))
