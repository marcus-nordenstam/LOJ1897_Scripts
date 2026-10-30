; ----------------------------------------------------------------------------
; go-to ?dest [earshot] - stand beside, near or inside ?dest: a spot, a thing, a person, a space or
; a building. To a person, its proposer says how near: earshot to talk with him, else near enough to
; reach him. Movement is go-to and cross, over DOMAINS - an enclosure, a unit or a building with
; rooms of its own; the outdoors is no domain, its way being the roads - and a WALK is planned within
; one domain. Between domains the way is a door: (spatial @self next-door ?dest) names the doors he
; must cross next, and go-to recurses on them - a door is crossed from the room on his side of it, and
; from anywhere else he first goes to that room. The rungs are a preemptive-or:
;
;   arrived                                     -> succeed
;   no box for it, believed in a space          -> go-to that space, where he will see it;
;                                                  there and still unseen -> fail
;   seen once, and where it is now lost          -> locate-person / locate-thing; that failed -> fail
;   unseen, its unit or house seen              -> locate it there; a search that shows it not -> fail
;   unseen, no house at its premises            -> find-building; a search that finds none -> fail
;   with the man he goes to, no spot free by him -> fail
;   a next door, in the room on his side of it  -> cross it
;   a next door, elsewhere                      -> go-to the room on his side of it
;   in a premises not holding it, no door known -> wander the premises
;   out of doors, its premises' doors unknown   -> go-to a spot by the premises, and seeing it
;                                                  teaches its doors
;   a door on the way and none to cross          -> fail: a door failed, or the wander or the walk
;                                                  up to it is done; untried is an expect
;   out of his sight                            -> WALK toward the space it is in, claiming
;                                                  nothing; walked there, still unseen -> fail
;   otherwise                                   -> WALK to the spot he will stand on
;
; The world decides where a walk stops: a WALK whose way the world bars ends before the door and
; he sees it, and the next look names it the next door.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

; The seen premises of an unplaced ?dest's address: its unit, else the building, or @nothing.
(define-func go-house-at-premises (?dest)
  (bind @nothing ?house)
  (if (any {?dest address}): ?address
    (then (bind (seen-premises-at (address-household ?address.target)) ?house)
          (if (unsubstantial ?house)
            (then (bind (seen-premises-at (address-premises ?address.target)) ?house)))))
  ?house)

; The STANCE a go-to to a man takes, its auxiliary: earshot - near enough to talk with him - else
; reach, close enough to lay a hand on him.
(define-func go-earshot (?go-to)
  (cond (case (unsubstantial ?go-to.auxiliary) @false)
        (else (eq ?go-to.auxiliary earshot))))

; At a spot: standing on it. In a space: inside it, or out of doors in an exterior one. At a man:
; on the spot by him this go-to walked him onto. At a thing: within reach of it.
(define-func go-arrived (?dest ?go-to)
  (cond (case (is-spot ?dest) (overlaps ?dest @self))
        (case (is-a ?dest [k building]) (spatial @self building ?dest))
        (case (is-a ?dest [k unit]) (spatial @self unit ?dest))
        (case (is-a ?dest [k space]) (within-space @self ?dest))
        (case (is-a ?dest [k human]) (and (spatial ?dest co-located @self)
                                           (substantial (any {@self WALK ? /succ /caused_by ?go-to}))))
        (else (spatial @self can-reach ?dest))): ?there
  ?there)

(define-func go-unseen (?dest)
  (flip (is-spot ?dest) @false (not (grounded ?dest))))

; No box for it, seen or remembered: unseen, or a placed thing out of his sight.
(define-func go-boxless (?dest)
  (flip (is-spot ?dest) @false (unsubstantial (tolerate (spatial ?dest bounds)))))

; Seen once, and the mind now knows neither its box nor its space: it moved out of sight, or was
; not where he looked for it.
(define-func go-lost (?dest)
  (flip (is-spot ?dest) @false (and (grounded ?dest)
                                     (go-boxless ?dest)
                                     (unsubstantial (tolerate (spatial ?dest space))))))

; Nothing left to try that would place ?dest: never seen, or seen and lost, with the searches the
; rungs above make spent; or believed in a space this go-to walked to without seeing it there.
(define-func go-unplaceable (?dest ?go-to)
  (or (go-unseen ?dest)
      (go-lost ?dest)
      (and (go-boxless ?dest)
           (substantial (any {@self go-to (tolerate (spatial ?dest space)) /succ /caused_by ?go-to})))
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

; The spot he will stand on: the spot itself, a claimed spot on a space's floor, by a man as the
; stance asks, or at a thing.
(define-func go-stand-spot (?dest ?go-to)
  (cond (case (is-spot ?dest) ?dest)
        (case (is-a ?dest [k space]) (stand-spot-in ?dest))
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

; Where he heads for ?dest out of his sight: the space it is in, a point there he claims nothing at.
(define-func go-sight-spot (?dest)
  (cond (case (is-a ?dest [k space]) (travel-spot ?dest))
        (case (substantial (tolerate (spatial ?dest space))) (travel-spot (spatial ?dest space)))
        (else @fail)))

; The spot the next WALK in his domain heads for: where he will stand by ?dest once he sees it,
; else toward the space it is in.
(define-func go-walk-spot (?dest ?go-to)
  (flip (go-in-sight ?dest) (go-stand-spot ?dest ?go-to) (go-sight-spot ?dest)))

; He walked to where ?dest is for this go-to and still does not see it.
(define-func go-walked-blind (?dest ?go-to)
  (bind @false ?walked)
  (if (not (go-in-sight ?dest))
      (then (bind (go-sight-spot ?dest) ?spot)
            (if (is-spot ?spot)
                (then (bind (substantial (any {@self WALK ?spot /succ /caused_by ?go-to})) ?walked)))))
  ?walked)

; The premises ?dest stands in - a unit, or a building holding no unit he knows - or @nothing out
; of doors.
(define-func go-dest-place (?dest)
  (cond (case (is-spot ?dest) (spatial ?dest space))
        (case (is-a ?dest [k space]) ?dest)
        (else (tolerate (spatial ?dest space)))): ?space
  (place-holding ?space))

; This go-to has already failed to reach the room on his side of ?door.
(define-func go-near-room-failed (?door ?go-to)
  (passage-near-side ?door): ?room
  (substantial (any {@self go-to ?room /fail /caused_by ?go-to})))

; He stands in a premises that does not hold ?dest.
(define-func go-beyond-my-place (?dest)
  (place-holding (spatial @self space)): ?mine
  (and (substantial ?mine) (not (eq ?mine (go-dest-place ?dest)))))

; He stands out of doors and ?dest stands in a premises.
(define-func go-outside-its-place (?dest)
  (and (unsubstantial (place-holding (spatial @self space)))
       (substantial (go-dest-place ?dest))))

(task {@self go-to ?dest}:?go-to
  (lint-waive task-no-preparation)
  (success-cond (go-arrived ?dest ?go-to))
  (failure-cond (or (go-unplaceable ?dest ?go-to) (go-no-room ?dest ?go-to)))
  (init
    (check (or (is-spot ?dest) (is-a ?dest [k thing])))
    (check (go-reachable ?dest)))
  (preemptive-or
    (try (role ?space (spatial ?dest space)
           (role @self (go-boxless ?dest)
                       -{@self go-to ?space /fail /caused_by ?go-to}
             (effects (maintain-proposal {@self go-to ?space})))))
    (try (role @self (go-lost ?dest)
                     (is-a ?dest [k human])
                     -{@self locate-person ?dest /fail /caused_by ?go-to}
           (effects (maintain-proposal {@self locate-person ?dest}))))
    (try (role @self (go-lost ?dest)
                     (not (is-a ?dest [k human]))
                     -{@self locate-thing ?dest /fail /caused_by ?go-to}
           (effects (maintain-proposal {@self locate-thing ?dest}))))
    (try (role @self (go-unseen ?dest)
                     (substantial (go-house-at-premises ?dest))
                     (one-premises (go-house-at-premises ?dest))
                     -{@self locate ?dest (go-house-at-premises ?dest) /fail /caused_by ?go-to}
           (effects (maintain-proposal {@self locate ?dest (go-house-at-premises ?dest)}))))
    (try (role @self (go-unseen ?dest)
                     (unsubstantial (go-house-at-premises ?dest))
                     -{@self find-building ?dest ? /fail /caused_by ?go-to}
           (effects
             (check (substantial (any {?dest address})))
             (maintain-proposal {@self find-building ?dest (current-exterior @self)}))))
    ; THE WAY THROUGH DOORS (next-door): the next door he must cross is crossed from the room on
    ; his side of it, and from anywhere else he first goes to that room.
    (try (role ?door (spatial @self next-door ?dest)
                     (not (has-facet ?door nav_last_resort))
                     (in-near-room ?door)
                     -{@self cross ?door /fail /caused_by ?go-to}
                     (select (score (near @self ?door)) (policy argmax unknown-last))
           (effects (maintain-proposal {@self cross ?door}))))
    (try (role ?door (spatial @self next-door ?dest)
                     (not (has-facet ?door nav_last_resort))
                     (substantial (passage-near-side ?door))
                     (not (go-near-room-failed ?door ?go-to))
                     -{@self cross ?door /fail /caused_by ?go-to}
                     (select (score (near @self ?door)) (policy argmax unknown-last))
           (effects (maintain-proposal {@self go-to (passage-near-side ?door)}))))
    ; No door known to cross: inside a premises that does not hold ?dest he wanders it to find one;
    ; out of doors, he goes to a spot by the premises that holds it, and seeing it teaches its doors.
    (try (role @self (go-beyond-my-place ?dest)
                     -{@self wander (place-holding (spatial @self space)) /succ /caused_by ?go-to}
           (effects (maintain-proposal {@self wander (place-holding (spatial @self space))}))))
    (try (role @self (go-outside-its-place ?dest)
                     -{@self go-to ? /succ /caused_by ?go-to}
           (when (stand-spot-by (go-dest-place ?dest)): ?spot (is-spot ?spot))
           (effects (maintain-proposal {@self go-to ?spot}))))
    (try (role @self (or (go-beyond-my-place ?dest)
                         (go-outside-its-place ?dest)
                         (substantial (any {@self cross ? /fail /caused_by ?go-to})))
           (effects
             (expect (or (substantial (any {@self go-to ? /succ /caused_by ?go-to}))
                         (substantial (any {@self cross ? /fail /caused_by ?go-to}))
                         (substantial (any {@self wander ? /succ /caused_by ?go-to})))
                     "go-to: a door on the way and none he can cross, untried")
             (set-outcome ?go-to /fail))))
    (try (when (go-walk-spot ?dest ?go-to): ?spot (is-spot ?spot))
         (effects (maintain-proposal {@self WALK ?spot})))))
