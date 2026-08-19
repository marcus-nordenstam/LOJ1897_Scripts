(include "../../definitions/roles.hs")

(define-macro take-effects (?hand ?item ?take-action)
  (do
    ; these will fire in non-shipping builds, indicating badly designed rules that propose this action
    (check (not (= (spatial ?item gripped_by /env) ?hand)))
    (check (spatial @self co-located ?item))
    (spatial-write ?item gripped_by ?hand)
    (set-outcome ?take-action succ)))

(npc-action {@self LEFT_TAKE ?item}:?take-action
  (duration 1)
  (effects (take-effects (spatial @self left_hand) ?item ?take-action)))

(npc-action {@self RIGHT_TAKE ?item}:?take-action
  (duration 1)
  (effects (take-effects (spatial @self right_hand) ?item ?take-action)))
