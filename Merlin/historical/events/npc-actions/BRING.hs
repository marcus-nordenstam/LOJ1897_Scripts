; ----------------------------------------------------------------------------
; bring (npc-action) - the put-down completion of the general bring lane
; (npc-think/bring_think.hs). Fires ONLY at the destination (the same at-place
; gate the promotion think used): every carried item of the ware's kind is put
; down in the space @self stands in. The held set is the env-truth hold view
; (both hands, kind-filtered).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-action {@self BRING ?ware ?dest}
  (duration 5)
  (effects
    (for-each ?item (spatial @self hold ?ware /env)
        (put-item ?item (attr @self location)))
    (set-outcome {@self BRING ?ware ?dest} succ)))
