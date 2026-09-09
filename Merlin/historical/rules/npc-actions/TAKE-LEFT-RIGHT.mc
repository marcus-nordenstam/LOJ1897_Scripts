(include "../../definitions/roles.mc")

(define-macro take-effects (?hand ?item ?take-action)
  (do
    ; these will fire in non-shipping builds, indicating badly designed rules that propose this action
    (check (!= (spatial ?item gripped-by /env) ?hand))
    (check (spatial @self co-located ?item))
    (spatial-write ?item gripped-by ?hand /env)
    (set-outcome ?take-action /succ)))

(npc-action {@self LEFT-TAKE ?item}:?take-action-rel
  (duration 1)
  (effects
    (spatial @self left-hand /env): ?hand
    (take-effects ?hand ?item ?take-action-rel)))

(npc-action {@self RIGHT-TAKE ?item}:?take-action-rel
  (duration 1)
  (effects
    (spatial @self right-hand /env): ?hand
    (take-effects ?hand ?item ?take-action-rel)))
