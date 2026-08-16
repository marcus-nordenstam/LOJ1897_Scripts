(include "../../definitions/roles.hs")

(define-macro take-effects (?hand ?item ?take-action)
  (do
    ; these will fire in non-shipping builds, indicating badly designed rules that propose this action
    (check (not {?item controlled_by ?hand}))
    (check (not {?hand control ?item}))
    ; implement the actual "put effects"
    (add-attr-item ?hand control ?item)
    (set-attr ?item controlled_by ?hand)
    ; remove the item from the location it's in
    (check (co-present @self ?item))
    (remove-content ?item (location ?item))
    ; the put is now successfully complete
    (set-outcome ?take-action succ)))

(npc-action {@self LEFT_TAKE ?item}:?take-action
  (duration 1)
  (effects (take-effects (attr left_hand) ?item ?take-action)))

(npc-action {@self RIGHT_TAKE ?item}:?take-action
  (duration 1)
  (effects (take-effects (attr right_hand) ?item ?take-action)))
