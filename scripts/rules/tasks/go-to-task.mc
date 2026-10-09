; ----------------------------------------------------------------------------
; go-to ?dest - stand beside or near ?dest, never across a passage. ?dest is a spot, a thing or
; a person. The rungs are a preemptive-or, so each reads only what makes it the one to run:
;
;   arrived                                -> succeed
;   unseen, believed in a space            -> enter that space, where he will see it; entered
;                                             and still unseen -> fail
;   unseen, a house seen at its premises   -> locate it there; a search that shows it not -> fail
;   unseen, no house at its premises       -> find-building; a search that finds none -> fail
;   its space not trivially linked to mine -> enter it, and the doors are enter's; failed -> fail
;   in my closure                          -> WALK to the spot he will stand on
;
; A go-to never meets a door: enter and cross do. Every test here is cast on a role, so a rung
; costs nothing until a write admits it; the one (when ..) is the stand spot, a claim that polls.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

; The seen building standing at the premises of an unplaced ?dest's address, or @nothing.
(define-func go-house-at-premises (?dest)
  (bind @nothing ?house)
  (if (any {?dest address}): ?address
    (then (bind (seen-premises-at (address-premises ?address.target)) ?house)))
  ?house)

; At a spot: standing on it. In a space: filed in it. At a man: on the spot before him this
; go-to walked him onto. At a thing: in its space and within reach, or on the spot by it this
; go-to walked him onto - the nearest free floor to a thing set on furniture can be out of reach.
(define-func go-arrived (?dest ?go-to)
  (cond (case (is-spot ?dest) (overlaps ?dest @self))
        (case (is-a ?dest [k building]) (spatial @self building ?dest))
        (case (is-a ?dest [k unit]) (spatial @self unit ?dest))
        (case (is-a ?dest [k space]) (spatial @self space ?dest))
        (case (is-a ?dest [k human]) (and (spatial ?dest co-located @self)
                                           (substantial (any {@self WALK ? /succ /caused_by ?go-to}))))
        (else (and (spatial ?dest co-located @self)
                   (or (< (distance @self ?dest) (near_reach_m))
                       (substantial (any {@self WALK ? /succ /caused_by ?go-to})))))): ?there
  ?there)

(define-func go-unseen (?dest)
  (and (not (is-spot ?dest)) (not (grounded ?dest))))

; A dest go-to can reach: a spot, a thing he has placed, one he believes in some space, or one
; whose address he knows.
(define-func go-reachable (?dest)
  (or (is-spot ?dest)
      (grounded ?dest)
      (substantial (tolerate (spatial ?dest space)))
      (substantial (any {?dest address}))))

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
                       -{@self enter ?space /succ /caused_by ?go-to}
                       -{@self enter ?space /fail /caused_by ?go-to}
             (effects (maintain-proposal {@self enter ?space})))))
    (try (role ?space (spatial ?dest space)
           (role @self (go-unseen ?dest)
                       {@self enter ?space /succ /caused_by ?go-to}
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
    (try (role ?there (spatial ?dest space)
           (role @self (not (spatial (spatial @self space) trivially-linked ?there))
                       -{@self enter ?there /fail /caused_by ?go-to}
             (effects (maintain-proposal {@self enter ?there})))))
    (try (role @self {@self enter ? /fail /caused_by ?go-to}
           (effects (set-outcome ?go-to /fail))))
    (try (when (go-stand-spot ?dest): ?spot (is-spot ?spot))
         (effects (maintain-proposal {@self WALK ?spot})))
    (try (role @self (grounded ?dest) (not (is-spot ?dest))
           (effects (expect @false "go-to: a placed thing with no spot to stand on"))))))
