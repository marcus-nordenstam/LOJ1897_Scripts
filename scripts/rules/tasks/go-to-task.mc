; ----------------------------------------------------------------------------
; go-to ?dest - stand beside, near or inside ?dest: a spot, a thing, a person, a space or a
; building. Movement is go-to and cross, over DOMAINS - an enclosure, or one exterior space - and
; a go-to WALK never leaves its domain: between domains the way is the containment tree, one leg
; at a time, (spatial @self leg ?dest) naming the next. The rungs are a preemptive-or:
;
;   arrived                                     -> succeed
;   unseen, believed in a space                 -> go-to that space, where he will see it;
;                                                  there and still unseen -> fail
;   unseen, a house seen at its premises        -> locate it there; a search that shows it not -> fail
;   unseen, no house at its premises            -> find-building; a search that finds none -> fail
;   the leg is an enclosure                     -> cross its nearest door he has not failed,
;                                                  out of it or into it
;   the leg is the enclosure he stands in       -> no door left: wander it
;   the leg is an enclosure he stands outside   -> no door of it known: go-to a spot by it,
;                                                  and seeing it teaches its doors
;   the leg is an enclosure, tried              -> walked up to it, a door failed or the
;                                                  wander is done, and no door left: fail
;   the leg is an exterior space                -> WALK into it
;   in his domain, a door he believes shut on
;   every way he knows                          -> cross it; that cross failed -> fail
;   in his domain                               -> WALK to the spot he will stand on
;
; The world decides where a walk stops: a WALK whose way the world bars ends before the door and
; he sees it, and the barrier rung crosses it on the next look.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

; The seen building standing at the premises of an unplaced ?dest's address, or @nothing.
(define-func go-house-at-premises (?dest)
  (bind @nothing ?house)
  (if (any {?dest address}): ?address
    (then (bind (seen-premises-at (address-premises ?address.target)) ?house)))
  ?house)

; At a spot: standing on it. In a space: inside it, or out of doors in an exterior one. At a man: on the spot before him this
; go-to walked him onto. At a thing: in its space and within reach, or on the spot by it this
; go-to walked him onto - the nearest free floor to a thing set on furniture can be out of reach.
(define-func go-arrived (?dest ?go-to)
  (cond (case (is-spot ?dest) (overlaps ?dest @self))
        (case (is-a ?dest [k building]) (spatial @self building ?dest))
        (case (is-a ?dest [k unit]) (spatial @self unit ?dest))
        (case (is-a ?dest [k space]) (within-space @self ?dest))
        (case (is-a ?dest [k human]) (and (spatial ?dest co-located @self)
                                           (substantial (any {@self WALK ? /succ /caused_by ?go-to}))))
        (else (and (spatial ?dest co-located @self)
                   (or (< (distance @self ?dest) (near_reach_m))
                       (substantial (any {@self WALK ? /succ /caused_by ?go-to})))))): ?there
  ?there)

(define-func go-unseen (?dest)
  (if (is-spot ?dest) (then @false) (else (not (grounded ?dest)))))

; A thing he has placed: grounded, and no spot.
(define-func go-placed-thing (?dest)
  (if (is-spot ?dest) (then @false) (else (grounded ?dest))))

; A dest go-to can reach: a spot, a thing he has placed, one he believes in some space, or one
; whose address he knows.
(define-func go-reachable (?dest)
  (cond (case (is-spot ?dest) @true)
        (else (or (grounded ?dest)
                  (substantial (tolerate (spatial ?dest space)))
                  (substantial (any {?dest address}))))))

; Where the next WALK heads for a thing with no spot of its own: its box, seen or remembered.
(define-func go-travel-spot (?dest)
  (tolerate (travel-spot (known-box ?dest))): ?spot
  ?spot)

; The spot he will stand on: the spot itself, a claimed spot on a space's floor, before a man,
; or by a thing.
(define-func go-stand-spot (?dest)
  (cond (case (is-spot ?dest) ?dest)
        (case (is-a ?dest [k space]) (stand-spot-in ?dest))
        (case (is-a ?dest [k human]) (stand-spot-before ?dest))
        (case (substantial (tolerate (spatial ?dest bounds))) (stand-spot-by ?dest))
        (else (go-travel-spot ?dest))): ?spot
  ?spot)

(task {@self go-to ?dest}:?go-to
  (init
    (check (or (is-spot ?dest) (is-a ?dest [k thing])))
    (check (go-reachable ?dest)))
  (cease (if (go-arrived ?dest ?go-to) (then (set-outcome ?go-to /succ))))
  (preemptive-or
    (try (role @self (go-arrived ?dest ?go-to)
           (effects (set-outcome ?go-to /succ))))
    (try (role ?space (spatial ?dest space)
           (role @self (go-unseen ?dest)
                       -{@self go-to ?space /succ /caused_by ?go-to}
                       -{@self go-to ?space /fail /caused_by ?go-to}
             (effects (maintain-proposal {@self go-to ?space})))))
    (try (role ?space (spatial ?dest space)
           (role @self (go-unseen ?dest)
                       {@self go-to ?space /succ /caused_by ?go-to}
             (effects (set-outcome ?go-to /fail)))))
    (try (role @self (go-unseen ?dest)
                     (substantial (go-house-at-premises ?dest))
                     -{@self locate ?dest (go-house-at-premises ?dest) /fail /caused_by ?go-to}
           (effects (maintain-proposal {@self locate ?dest (go-house-at-premises ?dest)}))))
    (try (role @self (go-unseen ?dest)
                     (unsubstantial (go-house-at-premises ?dest))
                     -{@self find-building ?dest ? /fail /caused_by ?go-to}
           (effects
             (check (substantial (any {?dest address})))
             (maintain-proposal {@self find-building ?dest (current-exterior @self)}))))
    (try (role @self (go-unseen ?dest)
           (effects (set-outcome ?go-to /fail))))
    (try (role ?leg (spatial @self leg ?dest)
           (role @self (not (is-a ?leg [k exterior-space]))
             (role ?passage (spatial ?leg exits)
                            -{@self cross ?passage ? /fail /caused_by ?go-to}
                            (substantial (tolerate (spatial ?passage beyond (spatial @self space))))
                            (select (score (near @self ?passage)) (policy argmax))
               (role ?to (spatial ?passage beyond (spatial @self space))
                 (effects (maintain-proposal {@self cross ?passage ?to})))))))
    (try (role ?leg (spatial @self leg ?dest)
           (role @self (spatial @self space ?leg)
                       -{@self wander ?leg /succ /caused_by ?go-to}
             (effects (maintain-proposal {@self wander ?leg})))))
    (try (role ?leg (spatial @self leg ?dest)
           (role @self (not (is-a ?leg [k exterior-space]))
                       (empty (spatial ?leg exits))
                       -{@self go-to ? /succ /caused_by ?go-to}
             (when (stand-spot-by ?leg): ?spot (is-spot ?spot))
             (effects (maintain-proposal {@self go-to ?spot})))))
    (try (role ?leg (spatial @self leg ?dest)
           (role @self (not (is-a ?leg [k exterior-space]))
                       (or {@self go-to ? /succ /caused_by ?go-to}
                           {@self cross ? /fail /caused_by ?go-to}
                           {@self wander ?leg /succ /caused_by ?go-to})
             (effects (set-outcome ?go-to /fail)))))
    (try (role ?leg (spatial @self leg ?dest)
           (role @self (is-a ?leg [k exterior-space])
             (when (stand-spot-in ?leg): ?spot (is-spot ?spot))
             (effects (maintain-proposal {@self WALK ?spot})))))
    (try (role ?passage (spatial @self barrier ?dest)
                        -{@self cross ?passage ? /fail /caused_by ?go-to}
           (role ?to (spatial ?passage beyond (spatial @self space))
             (effects (maintain-proposal {@self cross ?passage ?to})))))
    (try (role ?passage (spatial @self barrier ?dest)
                        {@self cross ?passage ? /fail /caused_by ?go-to}
           (effects (set-outcome ?go-to /fail))))
    (try (when (go-stand-spot ?dest): ?spot (is-spot ?spot))
         (effects (maintain-proposal {@self WALK ?spot})))
    (try (role @self (go-placed-thing ?dest)
           (effects (expect @false "go-to: a placed thing with no spot to stand on"))))))
