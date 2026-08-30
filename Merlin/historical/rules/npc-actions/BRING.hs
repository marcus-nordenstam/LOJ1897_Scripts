; ----------------------------------------------------------------------------
; bring (npc-action) - the put-down completion of the general bring lane
; (npc-think/bring_think.hs). Fires ONLY at the destination (the same at-place
; gate the promotion think used): every carried item of the ware's kind is put
; down in the space @self stands in. The held set is the env-truth hold view
; (both hands, kind-filtered).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")
(include "../../macros/collection-macros.hs")

(npc-action {@self BRING ?ware ?dest}
  (duration 5)
  (effects
    ; Put down each carried item of the ware kind. A carried PILE (the
    ; provisioner's basket) folds into a co-located same-content pile on
    ; landing (the larder absorbs it), else it becomes that space's pile.
    (for-each ?item (spatial @self hold ?ware /env)
        (do
          (spatial-write ?item location (spatial @self space /env))
          ; A put-down PILE folds into a co-located same-content pile (the larder
          ; absorbs the basket, basket destroyed); with none, it BECOMES the pile.
          (if (is-a ?item [k pile])
              (then
                (attr ?item content_kind): ?deposited_kind
                (spatial ?item space /env): ?deposited_space
                (bind 0 ?larder)
                (for-each ?other (spatial ?deposited_space contents [k pile] /env)
                  (if (and (!= ?other ?item) (attr-is ?other content_kind ?deposited_kind))
                      (then (bind ?other ?larder))))
                (if ?larder
                    (then (pile-add ?larder (attr ?item count))
                          (destroy-entity ?item)))))))
    (set-outcome {@self BRING ?ware ?dest} /succ)))
