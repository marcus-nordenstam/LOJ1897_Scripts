; ----------------------------------------------------------------------------
; find-building - the venue-discovery search. A seek rule PROPOSES (maintain-proposal)
; the {@self find-building [k building <kind>] ?region} task; these two tries ARE its
; body, decomposing the running search: cover the region one hop at a time, or conclude
; it failed.
; The head binds ?sought (the sought kind) + ?region (the region) off the matched task,
; and captures the task belief :?find_task-rel so the outcome try can conclude it.
;
;   find_survey hops to the CLOSEST unobserved structure. (latch-eval (closest-unobserved
;     ...): ?dest) LATCHES ?dest while the go act walks; the sibling (not (observed ?dest))
;     falls on ARRIVAL, resetting the latch so the next cycle re-binds the next structure.
;     walk to ?dest's THRESHOLD point, where perception teaches the building
;     and its kind - so the sought venue ends the search naturally (success is not stamped
;     here). Searching STRUCTURES, not the sought kind, keeps it non-telepathic.
;   find_exhausted fires once every structure is observed (closest-unobserved fails): the
;     sought kind was not found, so conclude /fail (no such venue).
;
; and (not stable-or): the guards are COMPLEMENTARY on closest-unobserved existence, so
; exactly one try is ever live - exclusivity is inherent in the gates.
; ----------------------------------------------------------------------------

; What the search was for, if @self has now seen it: a building of the sought KIND, or
; the house standing at the sought PLACE's premises. @nothing while it is still out there.
(define-func find-building-found (?sought)
  (bind @nothing ?found)
  (if (is-kind ?sought)
    (then
      (for-each ?rel (every {? address})
        (bind ?rel.subject ?b)
        (if (and (is-a ?b ?sought) (observed ?b))
          (then
            (bind ?b ?found)
            (break)))))
    (else
      (if (any {?sought address}): ?addr-rel
        (then (bind (seen-premises-at (address-premises ?addr-rel.target)) ?found)))))
  ?found)

(npc-task {@self find-building ?sought ?region}:?find_task-rel
  ; The frontier IS the exception: covering unexplored ground means asking the world what
  ; is out there that @self has not seen yet. Signed off deliberately.
  (lint-waive env-read-outside-action)
  (tar ?)
  (aux ?)
  ; Seeing the sought venue is what makes its proposer let go, so the withdrawal is where
  ; the search learns it succeeded.
  (cease (if (substantial (find-building-found ?sought)) (then (set-outcome ?find_task-rel /succ))))
  (preemptive-or
    (try
      (when (and (latch-eval (closest-unobserved [k structure] ?region): ?dest)
                 (observed ?dest /not)))
      ; The cell is COMPOSED from the venue's /env bounds, not from a box he remembers -
      ; he has never seen this one, that being the point of the lane. A cell carries no
      ; mind of its own, so what comes back is the same public spot either way; the plane
      ; rode in on the bounds handle, which is where the decision to look at the world
      ; belongs. He looks at the venue itself on arrival.
      ; (travel-cell ..) and not (env-cell ..): the latter SCANS the grid for an
      ; unoccupied spot, which materialises chunks around a venue he is nowhere near and
      ; for no gain - nothing is reserved at this range anyway. travel-cell encodes the
      ; cell the approach point lies in and touches no grid at all.
      (effects
        (travel-cell (spatial ?dest bounds /env)): ?spot
        (if (is-cell ?spot)
            (then (maintain-proposal {@self WALK ?spot}
                                     [/postlude (observe ?dest)])))))
    (try
      (effects (set-outcome ?find_task-rel /fail)))))
