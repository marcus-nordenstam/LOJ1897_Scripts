; ----------------------------------------------------------------------------
; go ?dest - THE movement task, and the only one a chain proposes: only go and its own legs
; (exit-unit / exit-building / enter-building / enter-unit) propose WALK. ?dest is anything a man can be bound for: a spot, a building,
; a room, a person, a thing. The rungs are a preemptive-or, so each reads only what makes it
; the one to run - every rung above it has already failed:
;
;   arrived                          -> succeed
;   unseen, believed in a space      -> go to that space, where he will see it; not there -> fail
;   unseen, in the house at premises -> tour the house; a tour that shows it not -> fail
;   in a unit that is not dest's     -> exit-unit
;   in the wrong building            -> exit-building
;   out of doors, dest's building
;     entered as a whole             -> enter-building (its shared door, or a unit-less one)
;   dest in a unit he is not in      -> enter-unit (its own door: from the street for a row
;                                       house, from the shared hallway for a block of flats)
;   unseen, no house at its premises -> find-building; a search that finds none -> fail
;   far from dest                    -> WALK to its travel spot: a heading, no search, no claim
;   near dest, or dest is a spot     -> WALK to the spot he will stand on: the dest spot, a
;                                       claimed spot on its floor, before him or by him
;
; FAR and NEAR split at near_building_m, and far is the NEGATION of near: a grounded thing
; with no box answers @unknown to (distance ..), and a distance he cannot measure is not near.
; They are two rungs because the WALK's spot is bound in the gate: as he comes near the far
; gate falls, which withdraws the heading, and the near rung admits with the stand spot.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

; The seen building standing at the premises of an unplaced ?dest's address, or @nothing.
(define-func go-house-at-premises (?dest)
  (bind @nothing ?house)
  (if (any {?dest address}): ?address
    (then (bind (seen-premises-at (address-premises ?address.target)) ?house)))
  ?house)

; The building ?dest lies in as @self believes it, @nothing for a dest out of doors. A spot
; lies in its anchor's building, and a spot on the ground in none.
(define-func go-building (?dest)
  (cond (case (is-spot ?dest) (tolerate (spatial (spot-anchor ?dest) building)))
        (case (not (grounded ?dest)) (go-house-at-premises ?dest))
        (case (is-a ?dest [k building]) ?dest)
        (else (tolerate (spatial ?dest building)))): ?b
  (if (substantial ?b) (then ?b) (else @nothing)))

; At a thing means in its space and either within reach of it or on the spot by it this go
; walked him onto - the nearest free floor to a thing set on furniture can be out of reach.
; At a man means on the spot before him: being near him from the side is not being with him.
(define-func go-arrived (?dest ?go)
  (cond (case (is-spot ?dest) (overlaps ?dest @self))
        (case (is-a ?dest [k building]) (spatial @self building ?dest))
        (case (is-a ?dest [k unit]) (spatial @self unit ?dest))
        (case (is-a ?dest [k space]) (spatial @self space ?dest))
        (case (is-a ?dest [k human]) (and (spatial ?dest co-located @self) (walked-before ?dest)))
        (else (and (spatial ?dest co-located @self)
                   (or (< (distance @self ?dest) (near_reach_m))
                       (substantial (any {@self WALK ? /succ /caused_by ?go})))))): ?there
  ?there)

; The unit ?dest lies in as @self believes it, @nothing for a dest in no unit.
(define-func go-unit (?dest)
  (cond (case (is-spot ?dest) (tolerate (spatial (spot-anchor ?dest) unit)))
        (case (not (grounded ?dest)) @nothing)
        (case (is-a ?dest [k unit]) ?dest)
        (else (tolerate (spatial ?dest unit)))): ?u
  (if (substantial ?u) (then ?u) (else @nothing)))

(define-func go-unseen (?dest)
  (and (not (is-spot ?dest)) (not (grounded ?dest))))

; A dest go can decompose: a spot, a thing he has placed, one he believes in some space, or
; one whose address he knows.
(define-func go-reachable (?dest)
  (or (is-spot ?dest)
      (grounded ?dest)
      (substantial (tolerate (spatial ?dest space)))
      (substantial (any {?dest address}))))

(define-func go-near (?dest)
  (< (distance @self ?dest) (near_building_m)))

; Where the next WALK heads while he is far from ?dest.
(define-func go-travel-spot (?dest)
  (tolerate (travel-spot (known-box ?dest))): ?spot
  ?spot)

; Where the next WALK heads once he is near ?dest, or ?dest is a spot: the spot he will stand on.
(define-func go-stand-spot (?dest)
  (cond (case (is-spot ?dest) ?dest)
        (case (is-a ?dest [k space]) (stand-spot-in ?dest))
        (case (is-a ?dest [k human]) (stand-spot-before ?dest))
        (case (substantial (tolerate (spatial ?dest bounds))) (stand-spot-by ?dest))
        (else (go-travel-spot ?dest))): ?spot
  ?spot)

(task {@self go ?dest}:?go
  (lint-waive env-read-outside-action)
  (init
    (check (or (is-spot ?dest) (is-a ?dest [k thing])))
    (check (go-reachable ?dest)))
  (cease (if (go-arrived ?dest ?go) (then (set-outcome ?go /succ))))
  (preemptive-or
    ; ARRIVED - read by a rung and not the task gate, so a go promoted where it already stands
    ; still concludes: a gate that never rises runs neither the rungs nor the cease.
    (try
      (when (go-arrived ?dest ?go))
      (effects (set-outcome ?go /succ)))
    (try
      (when (go-unseen ?dest)
            (tolerate (spatial ?dest space)): ?space
            (substantial ?space)
            -{@self go ?space /succ /caused_by ?go})
      (effects (maintain-proposal {@self go ?space})))
    (try
      (when (go-unseen ?dest)
            (tolerate (spatial ?dest space)): ?space
            {@self go ?space /succ /caused_by ?go})
      (effects (set-outcome ?go /fail)))
    (try
      (when (go-unseen ?dest)
            (go-building ?dest): ?house
            (substantial ?house)
            (spatial @self building ?house)
            -{@self wander ?house /succ /caused_by ?go})
      (effects
        (check (is-a ?house [k building]))
        (maintain-proposal {@self wander ?house})))
    (try
      (when (go-unseen ?dest)
            (go-building ?dest): ?house
            {@self wander ?house /succ /caused_by ?go})
      (effects (set-outcome ?go /fail)))
    (try
      (when (spatial @self unit): ?my-unit
            (substantial ?my-unit)
            (not (= (go-unit ?dest) ?my-unit)))
      (effects
        (check (is-a ?my-unit [k unit]))
        (maintain-proposal {@self exit-unit ?my-unit})))
    (try
      (when (spatial @self building): ?here
            (substantial ?here)
            (not (= (go-building ?dest) ?here)))
      (effects
        (check (is-a ?here [k building]))
        (maintain-proposal {@self exit-building ?here})))
    (try
      (when (unsubstantial (spatial @self building))
            (go-building ?dest): ?building
            (substantial ?building)
            (enters-as-building ?building))
      (effects
        (check (is-a ?building [k building]))
        (check (grounded ?building))
        (maintain-proposal {@self enter-building ?building})))
    (try
      (when (go-unit ?dest): ?unit
            (substantial ?unit)
            (not (spatial @self unit ?unit)))
      (effects
        (check (is-a ?unit [k unit]))
        (check (grounded ?unit))
        (maintain-proposal {@self enter-unit ?unit})))
    (try
      (when (go-unseen ?dest)
            -{@self find-building ?dest ? /fail}
            (current-exterior @self): ?region)
      (effects
        (check (substantial (any {?dest address})))
        (maintain-proposal {@self find-building ?dest ?region})))
    (try
      (when (go-unseen ?dest)
            {@self find-building ?dest ? /fail})
      (effects (set-outcome ?go /fail)))
    (try
      (when (not (is-spot ?dest))
            (not (go-near ?dest))
            (go-travel-spot ?dest): ?spot
            (is-spot ?spot))
      (effects (maintain-proposal {@self WALK ?spot})))
    (try
      (when (or (is-spot ?dest) (go-near ?dest))
            (go-stand-spot ?dest): ?spot
            (is-spot ?spot))
      (effects (maintain-proposal {@self WALK ?spot})))
    (try
      (when (grounded ?dest)
            (not (is-spot ?dest))
            (or (unsubstantial (known-box ?dest))
                (and (go-near ?dest)
                     (substantial (tolerate (spatial ?dest bounds)))
                     (unsubstantial (tolerate (spatial ?dest space))))))
      (effects (expect @false "go: a placed thing with no box to head for, or near and in no space he knows")))))
