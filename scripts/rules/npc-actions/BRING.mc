; ----------------------------------------------------------------------------
; bring (npc-action) - the put-down completion of the general bring lane
; (npc-think/hot/bring-think.mc). Fires ONLY at the destination (the same in-space
; gate the proposing think used): every carried item of the ware's kind is set down
; on ?cell, the floor cell the think claimed at the goal's destination - the act needs
; no destination of its own. The held set is the env-truth hold view (both hands,
; kind-filtered).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")
(include "../../macros/collection-macros.mc")

(npc-action {@self BRING ?ware ?cell}
  (duration (seconds 5 min))
  (effects
    ; Put down each carried item of the ware kind. A carried PILE (the
    ; provisioner's basket) folds into a co-located same-content pile on
    ; landing (the larder absorbs it), else it becomes that space's pile.
    (for-each ?item (spatial @self hold ?ware /env)
        (do
          (relocate ?item ?cell)
          ; A put-down PILE folds into a co-located same-content pile (the larder
          ; absorbs the basket, basket destroyed); with none, it BECOMES the pile.
          (if (is-a ?item [k pile])
              (then
                (attr ?item content-kind): ?deposited_kind
                (spatial ?item space /env): ?deposited_space
                (bind 0 ?larder)
                (for-each ?other (spatial ?deposited_space contents [k pile] /env)
                  (if (and (!= ?other ?item) (attr-is ?other content-kind ?deposited_kind))
                      (then (bind ?other ?larder))))
                (if ?larder
                    (then (pile-add ?larder (attr ?item count))
                          (destroy-entity ?item)))))))
    (set-outcome {@self BRING ?ware ?cell} /succ)))
