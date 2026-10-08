; ----------------------------------------------------------------------------
; bring (action) - the put-down completion of the general bring chain
; (thinks/hot/bring-think.mc). Fires ONLY at the destination (the same in-space
; gate the proposing think used): every carried ware - an instance of the ware kind, or
; a pile whose content is that kind - is set down on ?spot, the floor spot the think
; claimed at the goal's destination; the act needs no destination of its own. The held
; set is the env-truth hold view, which includes what he has stowed.
; ----------------------------------------------------------------------------

(include "../../macros/collection-macros.mc")

(action {@self BRING ?ware ?spot}:?BRING
  (motor body legs)
  (duration (seconds 5 min))
  (effects
    ; Put down each carried item of the ware kind. A carried PILE (the
    ; provisioner's basket) folds into a co-located same-content pile on
    ; landing (the larder absorbs it), else it becomes that space's pile.
    (for-each ?item (spatial @self hold /env)
      (if (or (is-a ?item ?ware)
              (and (is-a ?item [k pile]) (attr-is ?item content-kind ?ware)))
        (then
          (relocate ?item ?spot)
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
                    (then (set-attr ?larder count (+ (attr ?larder count) (attr ?item count)))
                          (destroy-entity ?item))))))))
    (set-outcome ?BRING /succ)))
