; ----------------------------------------------------------------------------
; enter-room ?room [?place] - stand INSIDE a room. ?room is a room he knows - or an exterior space,
; which is how he steps out of doors - or a room KIND, and then ?place is the building or unit to
; find one of that kind in (go-to-bed hands his home; locate-room the venue it found). A proposer
; whose place may be a building or a room (a workplace, a venue) names it as ?room, and a building or
; a unit is entered by enter-building.
;
; Of a kind: he enters the nearest room of it he knows in ?place, else locates one there; a place he
; finds none in fails it. A known room is reached through its doors: the next door toward it
; (next-door), crossed from the room on his side of it and from anywhere else after entering that
; room first; inside a premises that does not hold it with no door known, he wanders it; out of doors,
; he goes to stand by its premises, and seeing it teaches its doors; in the room's own domain with no
; door between, he walks in, to the free spot nearest its middle once he sees it, toward it until
; then; walked there and still not seeing it, he fails it.
;
; It is done when he stands in it and nothing it set moving still runs: a man is filed in a room
; part way through the step that takes him there, and the step goes on to its spot.
; ----------------------------------------------------------------------------

; The premises a room stands in - a unit, or a building holding no unit he knows - or @nothing for
; an exterior space.
(define-func enter-room-premises (?room)
  (place-holding ?room))

; He stands in a premises that does not hold ?room.
(define-func enter-room-beyond-my-place (?room)
  (place-holding (spatial @self space)): ?mine
  (and (substantial ?mine) (not (eq ?mine (enter-room-premises ?room)))))

; He stands out of doors and ?room stands in a premises.
(define-func enter-room-outside-its-place (?room)
  (and (unsubstantial (place-holding (spatial @self space)))
       (substantial (enter-room-premises ?room))))

; This enter-room has already failed to reach the room on his side of ?door.
(define-func enter-room-near-room-failed (?door ?enter-room)
  (passage-near-side ?door): ?near
  (substantial (any {@self enter-room ?near /fail /caused_by ?enter-room})))

; ?room is a building or a unit: enter-building's to enter.
(define-func enter-room-enclosure (?room)
  (and (is-object ?room) (or (is-a ?room [k building]) (is-a ?room [k unit]))))

; ?room names one room or exterior space, neither a kind nor an enclosure.
(define-func enter-room-known-room (?room)
  (flip (is-kind ?room) @false (not (enter-room-enclosure ?room))))

; Where the walk in heads: the free spot nearest its middle once he sees it, else toward it,
; claiming nothing.
(define-func enter-room-walk-spot (?room)
  (flip (is-visible ?room) (stand-spot-in ?room) (travel-spot ?room)))

; He walked toward ?room for this enter-room and still does not see it.
(define-func enter-room-walked-blind (?room ?enter-room)
  (and (not (is-visible ?room))
       (substantial (any {@self WALK (travel-spot ?room) /succ /caused_by ?enter-room}))))

; In the room - of the kind, in ?place - with no cross, walk or enter of this one still running.
(define-func enter-room-done (?room ?place ?enter-room)
  (and (cond (case (is-kind ?room) (and (stands-in-room ?room) (within-place @self ?place)))
             (case (enter-room-enclosure ?room) (within-place @self ?room))
             (else (within-space @self ?room)))
       (unsubstantial (any {@self enter-building ? /caused_by ?enter-room}))
       (unsubstantial (any {@self cross ? /caused_by ?enter-room}))
       (unsubstantial (any {@self WALK ? /caused_by ?enter-room}))
       (unsubstantial (any {@self enter-room ? /caused_by ?enter-room}))))

(task {@self enter-room ?room ?place}:?enter-room
  (lint-waive task-no-preparation)
  (tar ?)
  (aux ?)
  (success-cond (enter-room-done ?room ?place ?enter-room))
  (preemptive-or
    ; A BUILDING OR A UNIT.
    (try (role @self (enter-room-enclosure ?room)
                     -{@self enter-building ?room /fail /caused_by ?enter-room}
           (effects (maintain-proposal {@self enter-building ?room}))))
    (try (role @self (enter-room-enclosure ?room)
           (effects (set-outcome ?enter-room /fail))))
    ; A ROOM OF A KIND in ?place.
    (try (role ?known (spatial ?place rooms) (is-kind ?room) (is-a ?known ?room)
                      -{@self enter-room ?known /fail /caused_by ?enter-room}
                      (select (score (near @self ?known)) (policy roulette unknown-last))
           (effects (maintain-proposal {@self enter-room ?known}))))
    (try (role @self (is-kind ?room) -{@self locate ?room ?place /fail}
           (effects (maintain-proposal {@self locate ?room ?place}))))
    (try (role @self (is-kind ?room)
           (effects (set-outcome ?enter-room /fail))))
    ; A KNOWN ROOM, through its doors.
    (try (role @self (enter-room-known-room ?room)
           (role ?door (spatial @self next-door ?room)
                       (not (has-facet ?door nav_last_resort))
                       (in-near-room ?door)
                       -{@self cross ?door /fail /caused_by ?enter-room}
                       (select (score (near @self ?door)) (policy argmax unknown-last))
             (effects (maintain-proposal {@self cross ?door})))))
    (try (role @self (enter-room-known-room ?room)
           (role ?door (spatial @self next-door ?room)
                       (not (has-facet ?door nav_last_resort))
                       (substantial (passage-near-side ?door))
                       (not (enter-room-near-room-failed ?door ?enter-room))
                       -{@self cross ?door /fail /caused_by ?enter-room}
                       (select (score (near @self ?door)) (policy argmax unknown-last))
             (effects (maintain-proposal {@self enter-room (passage-near-side ?door)})))))
    (try (role @self (enter-room-known-room ?room)
                     (enter-room-beyond-my-place ?room)
                     -{@self wander (place-holding (spatial @self space)) /succ /caused_by ?enter-room}
           (effects (maintain-proposal {@self wander (place-holding (spatial @self space))}))))
    (try (role @self (enter-room-known-room ?room)
                     (enter-room-outside-its-place ?room)
                     -{@self go-to (enter-room-premises ?room) /succ /caused_by ?enter-room}
                     -{@self go-to (enter-room-premises ?room) /fail /caused_by ?enter-room}
           (effects (maintain-proposal {@self go-to (enter-room-premises ?room)}))))
    (try (role @self (enter-room-known-room ?room)
                     (or (enter-room-beyond-my-place ?room)
                         (enter-room-outside-its-place ?room)
                         (substantial (any {@self cross ? /fail /caused_by ?enter-room})))
           (effects
             (expect (or (substantial (any {@self go-to ? /succ /caused_by ?enter-room}))
                         (substantial (any {@self go-to ? /fail /caused_by ?enter-room}))
                         (substantial (any {@self cross ? /fail /caused_by ?enter-room}))
                         (substantial (any {@self wander ? /succ /caused_by ?enter-room})))
                     "enter-room: a door on the way and none he can cross, untried")
             (set-outcome ?enter-room /fail))))
    (try (role @self (enter-room-known-room ?room) (enter-room-walked-blind ?room ?enter-room)
           (effects (set-outcome ?enter-room /fail))))
    (try (role @self (enter-room-known-room ?room)
           (when (enter-room-walk-spot ?room): ?spot (is-spot ?spot))
           (effects (maintain-proposal {@self WALK ?spot}))))))
