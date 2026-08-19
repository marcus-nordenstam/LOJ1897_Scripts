(include "../../definitions/roles.hs")

(define-macro put-effects (?hand ?item ?location ?put-action)
  (do
    ; these will fire in non-shipping builds, indicating badly designed rules that propose this action
    (check (= (spatial ?item gripped_by /env) ?hand))
    (check (= (spatial @self space) ?location)) ; you must be in the dest-location to put something there
    (spatial-write ?item space ?location)
    (set-outcome ?put-action succ)))

(npc-action {@self LEFT_PUT ?item ?location}:?put-action
  (duration 1)
  (effects (put-effects (spatial @self left_hand) ?item ?location ?put-action)))

(npc-action {@self RIGHT_PUT ?item ?location}:?put-action
  (duration 1)
  (effects (put-effects (spatial @self right_hand) ?item ?location ?put-action)))
