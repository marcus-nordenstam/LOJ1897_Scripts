; ----------------------------------------------------------------------------
; bring (npc-action) - the put-down completion of the general bring lane
; (npc-think/bring_think.hs). Fires ONLY at the destination (the same at-place
; gate the promotion think used): every carried item of the ware's kind is put
; down in the space @self stands in. Held items live on the HAND entity
; (hand.control), not on @self.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-action {@self bring ?ware ?dest}
  (duration 5)
  (effects
    (bind (attr @self right_hand) ?hand)
    (if (is-entity ?hand)
        (then (for-each ?item (attr-values ?hand control)
          (if (is-a ?item ?ware)
              (then
                (put-item ?item (attr @self location)))))))
    (set-outcome {@self bring ?ware ?dest} succ)))
