; ----------------------------------------------------------------------------
; go-to ?dest [earshot] - stand BESIDE ?dest: a spot, a thing, a person, or a building or unit seen
; from outside. It never takes him into an enclosure - getting in is enter-building's and enter-room's.
; To a person, its proposer says how near: earshot to talk with him, else near enough to reach him.
; The rungs are a preemptive-or:
;
; It requires that he knows where ?dest is (placed): a find fills that before go-to is proposed.
;
;   arrived                                     -> succeed
;   no box for it, believed in a space          -> enter that space, where he will see it;
;                                                  there and still unseen -> fail
;   with the man he goes to, no spot free by him -> fail
;   it stands in a space he is not in           -> enter that space; that failed -> fail
;   out of his sight                            -> WALK toward the space it is in, claiming
;                                                  nothing; walked there, still unseen -> fail
;   otherwise                                   -> WALK to the spot he will stand on
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

; The STANCE a go-to to a man takes, its auxiliary: earshot - near enough to talk with him - else
; reach, close enough to lay a hand on him.
(define-func go-earshot (?go-to)
  (cond (case (unsubstantial ?go-to.auxiliary) @false)
        (else (eq ?go-to.auxiliary earshot))))

; A destination go-to cannot take: a room or an exterior space, which he goes INTO.
(define-func go-into-space (?dest)
  (flip (is-spot ?dest) @false (and (is-a ?dest [k space]) (not (is-a ?dest [k unit])))))

; At a spot: standing on it. At a man: on the spot by him this go-to walked him onto. At a thing, a
; building or a unit: within reach of it.
(define-func go-arrived (?dest ?go-to)
  (cond (case (is-spot ?dest) (overlaps ?dest @self))
        (case (is-a ?dest [k human]) (and (spatial ?dest co-located @self)
                                           (substantial (any {@self WALK ? /succ /caused_by ?go-to}))))
        (else (spatial @self can-reach ?dest))): ?there
  ?there)

; No box for it, seen or remembered: unseen, or a placed thing out of his sight.
(define-func go-boxless (?dest)
  (flip (is-spot ?dest) @false (unsubstantial (tolerate (spatial ?dest bounds)))))

; Where ?dest was believed to be, it is not: he entered the space it was believed in without seeing
; it there, or walked to it and still does not see it.
(define-func go-unplaceable (?dest ?go-to)
  (or (and (go-boxless ?dest)
           (substantial (any {@self enter-room (tolerate (spatial ?dest space)) /succ /caused_by ?go-to})))
      (go-walked-blind ?dest ?go-to)))

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

; Where he stands at a thing: by anything he has a box for, else toward the box he remembers.
(define-func go-thing-stand-spot (?dest)
  (cond (case (substantial (tolerate (spatial ?dest bounds))) (stand-spot-by ?dest))
        (else (go-travel-spot ?dest))): ?spot
  ?spot)

; The spot he will stand on: the spot itself, by a man as the stance asks, or at a thing - a building
; or a unit is a thing he stands by from outside.
(define-func go-stand-spot (?dest ?go-to)
  (cond (case (is-spot ?dest) ?dest)
        (case (and (is-a ?dest [k human]) (go-earshot ?go-to)) (earshot-spot-of ?dest))
        (case (is-a ?dest [k human]) (stand-spot-before ?dest))
        (else (go-thing-stand-spot ?dest))): ?spot
  ?spot)

; ?dest is a man @self is with and sees, and no spot is free to stand by him as the stance asks.
(define-func go-no-room (?dest ?go-to)
  (cond (case (is-spot ?dest) @false)
        (case (is-a ?dest [k human]) (and (spatial ?dest co-located @self)
                                          (is-visible ?dest)
                                          (not (is-spot (go-stand-spot ?dest ?go-to)))))
        (else @false)))

; A spot is placed by its own coordinates; anything else only once @self sees it, since finding
; where to stand by it is looking it over.
(define-func go-in-sight (?dest)
  (flip (is-spot ?dest) @true (is-visible ?dest)))

; Where he heads for ?dest out of his sight: a point in the space it is in, claiming nothing.
(define-func go-sight-spot (?dest)
  (cond (case (substantial (tolerate (spatial ?dest space))) (travel-spot (spatial ?dest space)))
        (else @fail)))

; The spot the next WALK heads for: where he will stand by ?dest once he sees it, else toward the
; space it is in.
(define-func go-walk-spot (?dest ?go-to)
  (flip (go-in-sight ?dest) (go-stand-spot ?dest ?go-to) (go-sight-spot ?dest)))

; He walked to where ?dest is for this go-to and still does not see it - the walk go-walk-spot
; heads on when he does not.
(define-func go-walked-blind (?dest ?go-to)
  (flip (go-in-sight ?dest)
        @false
        (and (is-spot (go-sight-spot ?dest))
             (substantial (any {@self WALK (go-sight-spot ?dest) /succ /caused_by ?go-to})))))

(task {@self go-to ?dest}:?go-to
  (requires (placed ?dest))
  (success-cond (go-arrived ?dest ?go-to))
  (failure-cond (or (go-unplaceable ?dest ?go-to) (go-no-room ?dest ?go-to)))
  (init
    (check (or (is-spot ?dest) (is-a ?dest [k thing])))
    (check (not (go-into-space ?dest))))
  (preemptive-or
    (try (role ?space (spatial ?dest space)
           (role @self (go-boxless ?dest)
                       -{@self enter-room ?space /fail /caused_by ?go-to}
             (effects (maintain-proposal {@self enter-room ?space})))))
    ; It stands in a space he is not in: he goes into that space first, through whatever doors lie
    ; between - a building's or a unit's space is the exterior it stands in.
    (try (role ?space (spatial ?dest space)
           (role @self (not (within-space @self ?space))
                       -{@self enter-room ?space /fail /caused_by ?go-to}
             (effects (maintain-proposal {@self enter-room ?space})))))
    (try (role ?space (spatial ?dest space)
           (role @self (not (within-space @self ?space))
                       {@self enter-room ?space /fail /caused_by ?go-to}
             (effects (set-outcome ?go-to /fail)))))
    (try (when (go-walk-spot ?dest ?go-to): ?spot (is-spot ?spot))
         (effects (maintain-proposal {@self WALK ?spot})))))
