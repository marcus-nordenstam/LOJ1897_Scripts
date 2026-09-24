; ----------------------------------------------------------------------------
; approach ?ent - the LONG-RANGE leg: bring @self within near_building_m of a thing he has
; placed, whether a building he is bound for, a man he wants a word with or a stack he
; means to read. Only go and enter propose it, and it proposes nothing but WALK.
;
; It heads for an ABS-CELL and reserves nothing: a rel-cell is the near, precise form, and
; claiming one is the proposer's business once he is close. The spot is read from the box
; he REMEMBERS, so a thing seen once can be walked to while it is out of sight; a structure
; he has never had a box for is read from the world's, since where a building stands is
; public knowledge.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")
(include "../../macros/tunables.mc")

(define-func approach-box (?ent)
  (tolerate (spatial ?ent bounds)): ?seen
  (tolerate (spatial ?ent bounds /most-recent-memory)): ?remembered
  (cond (case (substantial ?seen) ?seen)
        (case (substantial ?remembered) ?remembered)
        (case (is-a ?ent [k structure]) (spatial ?ent bounds /env))
        (else @nothing)): ?known
  ?known)

; Near enough that the proposer claims a rel-cell on it instead.
(define-func within-reach-of-claim (?ent)
  (< (distance @self ?ent) (near_building_m)))

(npc-task {@self approach ?ent}:?approach-rel
  (tar @excl [k thing] @object)
  (lint-waive env-read-outside-action)
  (init
    (check (not (is-cell ?ent)))
    (check (is-a ?ent [k thing]))
    (check (grounded ?ent)))
  (when (poll (not (within-reach-of-claim ?ent))))
  (cease (if (within-reach-of-claim ?ent) (then (set-outcome ?approach-rel /succ))))
  (and
    (try
      (when (poll (approach-box ?ent): ?box
                  (substantial ?box)))
      (effects
        (travel-cell ?box): ?spot
        (check (is-abs-cell ?spot))
        (maintain-proposal {@self WALK ?spot})))
    (try
      (when (poll (unsubstantial (approach-box ?ent))))
      (effects (expect @false "approach: a placed thing with no box to head for")))))
