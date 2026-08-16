(include "../../definitions/roles.hs")

(define-macro put-effects (?hand ?item ?location ?put-action)
  (do 
    ; these will fire in non-shipping builds, indicating badly designed rules that propose this action
    ; the NPC must KNOW that they are holding the item with their hand
    (check {?item controlled_by ?hand})
    (check {?hand control ?item})
    ; implement the actual "put effects"
    (remove-attr-item ?hand control ?item)
    (set-attr ?item controlled_by _)
    ; add the item to the dest-location
    (check (= (location @self) ?location)) ; you must be in the dest-location to put something there
    (add-content ?item ?location)
    ; the put is now successfully complete
    (set-outcome ?put-action succ)))

(npc-action {@self LEFT_PUT ?item ?location}:?put-action
  (duration 1)
  (effects (put-effects (attr left_hand) ?item ?location ?put-action)))

(npc-action {@self RIGHT_PUT ?item ?location}:?put-action
  (duration 1)
  (effects (put-effects (attr right_hand) ?item ?location ?put-action)))
