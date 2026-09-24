; ----------------------------------------------------------------------------
; go ?dest - THE movement task, and the only one a lane proposes. ?dest is anything a man
; can be bound for: a cell, a building, a room, a person, a thing. go decomposes it and
; never proposes itself, so no second go is ever nested under the first:
;
;   in the wrong building          -> exit it
;   out of doors, dest in building -> enter that building
;   dest unplaced, house not found -> find-building; inside the house -> wander it
;   dest far                       -> approach it (long range, an abs-cell)
;   dest near                      -> claim a rel-cell by it and WALK onto that cell
;   dest a cell                    -> WALK
;
; FAR and NEAR split at near_building_m, and far is the NEGATION of near: a grounded thing
; with no box answers @unknown to (distance ..), and a distance he cannot measure is not near.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

; The seen building standing at the premises of an unplaced ?dest's address, or @nothing.
(define-func go-house-at-premises (?dest)
  (bind @nothing ?house)
  (if (any {?dest address}): ?addr-rel
    (then (bind (seen-premises-at (address-premises ?addr-rel.target)) ?house)))
  ?house)

; What go heads for: ?dest itself, or - for a thing he has not perceived but believes is in
; some space - that space, until he stands in it and sees the thing there.
(define-func go-target (?dest)
  (cond (case (is-cell ?dest) ?dest)
        (case (grounded ?dest) ?dest)
        (case (is-a ?dest [k space]) ?dest)
        (case (is-a ?dest [k structure]) ?dest)
        (else (tolerate (spatial ?dest space)))): ?t
  (if (substantial ?t) (then ?t) (else ?dest)))

; The building ?dest lies in as @self believes it, @nothing for a dest out of doors. An
; abs-cell says nothing about buildings and answers @nothing too: it is the long-range form.
(define-func go-building (?dest)
  (cond (case (is-rel-cell ?dest) (tolerate (spatial (cell-anchor ?dest) building)))
        (case (is-abs-cell ?dest) @nothing)
        (case (not (grounded ?dest)) (go-house-at-premises ?dest))
        (case (is-a ?dest [k container-structure]) ?dest)
        (else (tolerate (spatial ?dest building)))): ?b
  (if (substantial ?b) (then ?b) (else @nothing)))

; @self stands in ?b, or out of doors when ?b is @nothing.
(define-func go-in-building (?b)
  (cond (case (substantial ?b) (spatial @self building ?b))
        (else (unsubstantial (spatial @self building)))): ?in
  ?in)

; At a thing means in its space and either within reach of it or on the spot by it this go
; walked him onto - the nearest free floor to a thing set on furniture can be out of reach.
(define-func go-arrived (?dest ?go-rel)
  (cond (case (is-cell ?dest) (overlaps ?dest @self))
        (case (is-a ?dest [k container-structure]) (spatial @self building ?dest))
        (case (is-a ?dest [k space]) (spatial @self space ?dest))
        (else (and (spatial ?dest co-located @self)
                   (or (< (distance @self ?dest) (near_reach_m))
                       (substantial (any {@self WALK ? /succ /caused_by ?go-rel})))))): ?there
  ?there)

; A target go can decompose: a cell, a thing he has placed, or one whose address he knows.
(define-func go-reachable (?t)
  (or (is-cell ?t) (grounded ?t) (substantial (any {?t address}))))

(define-func go-near (?dest)
  (< (distance @self ?dest) (near_building_m)))

(npc-task {@self go ?dest}:?go-rel
  (tar @excl)
  (init
    (check (or (is-cell ?dest) (is-a ?dest [k thing])))
    ; A rel-cell is measured from its anchor, so only a mind that grounded the anchor may hold one.
    (check (or (not (is-rel-cell ?dest)) (substantial (cell-anchor ?dest))))
    (check (go-reachable (go-target ?dest))))
  (cease (if (go-arrived ?dest ?go-rel) (then (set-outcome ?go-rel /succ))))
  (and
    ; ARRIVED - read by a rung and not the task gate, so a go promoted where it already stands
    ; still concludes: a gate that never rises runs neither the rungs nor the cease.
    (try
      (when (poll (go-arrived ?dest ?go-rel)))
      (effects (set-outcome ?go-rel /succ)))
    ; WRONG BUILDING: leave the one he stands in first. An abs-cell is walked from anywhere.
    (try
      (when (poll (not (go-arrived ?dest ?go-rel))
                  (go-target ?dest): ?t
                  (not (is-abs-cell ?t))
                  (spatial @self building): ?here
                  (not (= (go-building ?t) ?here))))
      (effects
        (check (is-a ?here [k container-structure]))
        (check (spatial @self building ?here))
        (maintain-proposal {@self exit ?here})))
    ; OUT OF DOORS and bound into a building: cross its threshold.
    (try
      (when (poll (not (go-arrived ?dest ?go-rel))
                  (go-target ?dest): ?t
                  (not (is-abs-cell ?t))
                  (unsubstantial (spatial @self building))
                  (go-building ?t): ?b
                  (substantial ?b)))
      (effects
        (check (is-a ?b [k container-structure]))
        (check (grounded ?b))
        (maintain-proposal {@self enter ?b})))
    ; UNPLACED and standing in the house at its premises: tour the house for it. Walking into
    ; the right room is what places it, which drops this rung and raises the NEAR ones.
    (try
      (when (poll (not (go-arrived ?dest ?go-rel))
                  (go-target ?dest): ?t
                  (not (is-cell ?t))
                  (not (grounded ?t))
                  (go-building ?t): ?b
                  (substantial ?b)
                  (spatial @self building ?b)
                  -{@self wander ?b /succ /caused_by ?go-rel}))
      (effects
        (check (is-a ?b [k container-structure]))
        (maintain-proposal {@self wander ?b})))
    ; ...and a tour that covered the house without placing it: it is not there.
    (try
      (when (poll (not (go-arrived ?dest ?go-rel))
                  (go-target ?dest): ?t
                  (not (is-cell ?t))
                  (not (grounded ?t))
                  (go-building ?t): ?b
                  (substantial ?b)
                  {@self wander ?b /succ /caused_by ?go-rel}))
      (effects (set-outcome ?go-rel /fail)))
    ; UNPLACED and no house he has seen stands at its premises: search the town for one.
    (try
      (when (poll (not (go-arrived ?dest ?go-rel))
                  (go-target ?dest): ?t
                  (not (is-cell ?t))
                  (not (grounded ?t))
                  (unsubstantial (go-building ?t))
                  (unsubstantial (spatial @self building))
                  -{@self find-building ?t ? /fail}
                  (current-exterior @self): ?rg))
      (effects
        (check (substantial (any {?t address})))
        (maintain-proposal {@self find-building ?t ?rg})))
    ; FAR from a placed thing in his own building, or out of doors with him: approach it.
    (try
      (when (poll (not (go-arrived ?dest ?go-rel))
                  (go-target ?dest): ?t
                  (not (is-cell ?t))
                  (grounded ?t)
                  (not (is-a ?t [k container-structure]))
                  (go-in-building (go-building ?t))
                  (not (go-near ?t))))
      (effects
        (check (grounded ?t))
        (maintain-proposal {@self approach ?t})))
    ; NEAR a space: a spot on its floor.
    (try
      (when (poll (not (go-arrived ?dest ?go-rel))
                  (go-target ?dest): ?t
                  (not (is-cell ?t))
                  (grounded ?t)
                  (is-a ?t [k space])
                  (go-in-building (go-building ?t))
                  (go-near ?t)))
      (when (poll (stand-cell-in ?t): ?cell))
      (effects
        (check (is-rel-cell ?cell))
        (check (= (cell-anchor ?cell) ?t))
        (maintain-proposal {@self WALK ?cell})))
    ; NEAR a thing he cannot see from where he stands: a rel-cell is measured from a box he
    ; perceives, so first walk to where he remembers it, which puts it in view.
    (try
      (when (poll (not (go-arrived ?dest ?go-rel))
                  (go-target ?dest): ?t
                  (not (is-cell ?t))
                  (grounded ?t)
                  (not (is-a ?t [k space]))
                  (not (is-a ?t [k container-structure]))
                  (go-in-building (go-building ?t))
                  (go-near ?t)
                  (unsubstantial (spatial ?t bounds))
                  (spatial ?t bounds /most-recent-memory): ?remembered
                  (substantial ?remembered)))
      (effects
        (travel-cell ?remembered): ?spot
        (check (is-abs-cell ?spot))
        (maintain-proposal {@self WALK ?spot})))
    ; NEAR a thing in view: a spot on the floor beside it.
    (try
      (when (poll (not (go-arrived ?dest ?go-rel))
                  (go-target ?dest): ?t
                  (not (is-cell ?t))
                  (grounded ?t)
                  (not (is-a ?t [k space]))
                  (not (is-a ?t [k container-structure]))
                  (go-in-building (go-building ?t))
                  (go-near ?t)
                  (substantial (spatial ?t bounds))
                  (spatial ?t space): ?around))
      (when (poll (stand-cell-by ?t): ?cell))
      (effects
        (check (is-rel-cell ?cell))
        (check (= (cell-anchor ?cell) ?around))
        (maintain-proposal {@self WALK ?cell})))
    ; NEAR a placed thing he cannot put in any space: nowhere to stand beside it.
    (try
      (when (poll (not (go-arrived ?dest ?go-rel))
                  (go-target ?dest): ?t
                  (not (is-cell ?t))
                  (grounded ?t)
                  (not (is-a ?t [k space]))
                  (not (is-a ?t [k container-structure]))
                  (go-in-building (go-building ?t))
                  (go-near ?t)
                  (unsubstantial (spatial ?t space))))
      (effects (expect @false "go: a near thing in no space he knows")))
    ; A CELL in his own building, out of doors with him, or an abs-cell: one leg.
    (try
      (when (poll (not (go-arrived ?dest ?go-rel))
                  (go-target ?dest): ?t
                  (is-cell ?t)
                  (or (is-abs-cell ?t) (go-in-building (go-building ?t)))))
      (effects
        (check (is-cell ?t))
        (maintain-proposal {@self WALK ?t})))))
