; ----------------------------------------------------------------------------
; go ?dest - THE movement task, and the only one a chain proposes: only go and its own legs
; (exit / enter) propose WALK. ?dest is anything a man can be bound for: a spot, a building,
; a room, a person, a thing. The rungs are a preemptive-or, so each reads only what makes it
; the one to run - every rung above it has already failed:
;
;   arrived                          -> succeed
;   unseen, believed in a space      -> go to that space, where he will see it; not there -> fail
;   unseen, in the house at premises -> tour the house; a tour that shows it not -> fail
;   in the wrong building            -> exit it
;   out of doors, dest in building   -> enter that building
;   unseen, no house at its premises -> find-building; a search that finds none -> fail
;   otherwise                        -> WALK: the dest spot; far, its travel spot; near, a
;                                       spot on its floor or by it
;
; FAR and NEAR split at near_building_m, and far is the NEGATION of near: a grounded thing
; with no box answers @unknown to (distance ..), and a distance he cannot measure is not near.
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
        (case (is-a ?dest [k container-structure]) ?dest)
        (else (tolerate (spatial ?dest building)))): ?b
  (if (substantial ?b) (then ?b) (else @nothing)))

; At a thing means in its space and either within reach of it or on the spot by it this go
; walked him onto - the nearest free floor to a thing set on furniture can be out of reach.
(define-func go-arrived (?dest ?go)
  (cond (case (is-spot ?dest) (overlaps ?dest @self))
        (case (is-a ?dest [k container-structure]) (spatial @self building ?dest))
        (case (is-a ?dest [k space]) (spatial @self space ?dest))
        (else (and (spatial ?dest co-located @self)
                   (or (< (distance @self ?dest) (near_reach_m))
                       (substantial (any {@self WALK ? /succ /caused_by ?go})))))): ?there
  ?there)

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

; Where the next WALK heads, once he stands in ?dest's building, or out of doors with it.
(define-func go-step-spot (?dest)
  (cond (case (is-spot ?dest) ?dest)
        (case (not (go-near ?dest)) (tolerate (travel-spot (known-box ?dest))))
        (case (is-a ?dest [k space]) (stand-spot-in ?dest))
        (case (substantial (tolerate (spatial ?dest bounds))) (stand-spot-by ?dest))
        (else (tolerate (travel-spot (known-box ?dest))))): ?spot
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
      (when (poll (go-arrived ?dest ?go)))
      (effects (set-outcome ?go /succ)))
    (try
      (when (poll (go-unseen ?dest)
                  (tolerate (spatial ?dest space)): ?space
                  (substantial ?space)
                  -{@self go ?space /succ /caused_by ?go}))
      (effects (maintain-proposal {@self go ?space})))
    (try
      (when (poll (go-unseen ?dest)
                  (tolerate (spatial ?dest space)): ?space
                  {@self go ?space /succ /caused_by ?go}))
      (effects (set-outcome ?go /fail)))
    (try
      (when (poll (go-unseen ?dest)
                  (go-building ?dest): ?house
                  (substantial ?house)
                  (spatial @self building ?house)
                  -{@self wander ?house /succ /caused_by ?go}))
      (effects
        (check (is-a ?house [k container-structure]))
        (maintain-proposal {@self wander ?house})))
    (try
      (when (poll (go-unseen ?dest)
                  (go-building ?dest): ?house
                  {@self wander ?house /succ /caused_by ?go}))
      (effects (set-outcome ?go /fail)))
    (try
      (when (poll (spatial @self building): ?here
                  (substantial ?here)
                  (not (= (go-building ?dest) ?here))))
      (effects
        (check (is-a ?here [k container-structure]))
        (maintain-proposal {@self exit ?here})))
    (try
      (when (poll (unsubstantial (spatial @self building))
                  (go-building ?dest): ?building
                  (substantial ?building)))
      (effects
        (check (is-a ?building [k container-structure]))
        (check (grounded ?building))
        (maintain-proposal {@self enter ?building})))
    (try
      (when (poll (go-unseen ?dest)
                  -{@self find-building ?dest ? /fail}
                  (current-exterior @self): ?region))
      (effects
        (check (substantial (any {?dest address})))
        (maintain-proposal {@self find-building ?dest ?region})))
    (try
      (when (poll (go-unseen ?dest)
                  {@self find-building ?dest ? /fail}))
      (effects (set-outcome ?go /fail)))
    (try
      (when (poll (go-step-spot ?dest): ?spot
                  (is-spot ?spot)))
      (effects (maintain-proposal {@self WALK ?spot})))
    (try
      (when (poll (grounded ?dest)
                  (not (is-spot ?dest))
                  (or (unsubstantial (known-box ?dest))
                      (and (go-near ?dest)
                           (substantial (tolerate (spatial ?dest bounds)))
                           (unsubstantial (tolerate (spatial ?dest space)))))))
      (effects (expect @false "go: a placed thing with no box to head for, or near and in no space he knows")))))
