; ----------------------------------------------------------------------------
; enter-room ?room - stand INSIDE a room he knows, or an exterior space, which is how he steps out
; of doors. A proposer whose place may be a building or a room (a workplace, a venue) names it as
; ?room, and a building or a unit is entered by enter-building. A room of a kind is enter-room-kind's.
;
; Its precondition is that he knows where the room is (placed): a find achieves that. The room is reached
; through its doors: the next door toward it (next-door), crossed from the room on his side of it
; and from anywhere else after entering that room first; inside a premises that does not hold it
; with no door known, he wanders it; out of doors, he goes to stand by its premises, and seeing it
; teaches its doors; in the room's own domain with no door between, he walks in, to the free spot
; nearest its middle once he sees it, toward it until then; walked there and still not seeing it, he
; fails it.
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

; ?room is a building or a unit: enter-building's to enter.
(define-func enter-room-enclosure (?room)
  (and (is-object ?room) (or (is-a ?room [k building]) (is-a ?room [k unit]))))

; Where the walk in heads: the free spot nearest its middle once he sees it, else toward it,
; claiming nothing.
(define-func enter-room-walk-spot (?room)
  (flip (visible ?room) (claim (stand-spot-in ?room)) (travel-spot ?room)))

; He walked toward ?room for this enter-room and still does not see it - the walk
; enter-room-walk-spot heads on when he does not.
(define-func enter-room-walked-blind (?room ?enter-room)
  (flip (visible ?room)
        @false
        (substantial (any {@self WALK (travel-spot ?room) /succ /caused_by ?enter-room}))))

; In the room, with no cross, walk or enter of this one still running.
(define-func enter-room-done (?room ?enter-room)
  (and (flip (enter-room-enclosure ?room) (within-place @self ?room) (within-space @self ?room))
       (unsubstantial (any {@self enter-building|cross|WALK|enter-room ? /caused_by ?enter-room}))))

(task {@self enter-room ?room}:?enter-room
  (tar ?)
  (preconditions (placed ?room))
  (success-cond (enter-room-done ?room ?enter-room))
  (preemptive-or
    ; A BUILDING OR A UNIT.
    (try (role @self (enter-room-enclosure ?room)
                     -{@self enter-building ?room /fail /caused_by ?enter-room}
           (effects (maintain-proposal {@self enter-building ?room} /tolerate-fail))))
    (try (role @self (enter-room-enclosure ?room)
           (effects (set-outcome ?enter-room /fail))))
    ; A ROOM, through its doors.
    (try (role ?door (spatial @self next-door ?room)
                     (not (has-facet ?door nav_last_resort))
                     (in-near-room ?door)
                     -{@self cross ?door /fail /caused_by ?enter-room}
                     (select (score (near @self ?door)) (policy argmax unknown-last))
           (effects (maintain-proposal {@self cross ?door} /tolerate-fail))))
    (try (role ?door (spatial @self next-door ?room)
                     (not (has-facet ?door nav_last_resort))
                     (substantial (passage-near-side ?door))
                     -{@self enter-room (passage-near-side ?door) /fail /caused_by ?enter-room}
                     -{@self cross ?door /fail /caused_by ?enter-room}
                     (select (score (near @self ?door)) (policy argmax unknown-last))
           (effects (maintain-proposal {@self enter-room (passage-near-side ?door)} /tolerate-fail))))
    (try (role @self (enter-room-beyond-my-place ?room)
                     -{@self wander (place-holding (spatial @self space)) /succ /caused_by ?enter-room}
           (effects (maintain-proposal {@self wander (place-holding (spatial @self space))} /tolerate-fail))))
    (try (role @self (enter-room-outside-its-place ?room)
                     -{@self go-to (enter-room-premises ?room) /succ /caused_by ?enter-room}
                     -{@self go-to (enter-room-premises ?room) /fail /caused_by ?enter-room}
           (effects (maintain-proposal {@self go-to (enter-room-premises ?room)} /tolerate-fail))))
    (try (role @self (or (enter-room-beyond-my-place ?room)
                         (enter-room-outside-its-place ?room)
                         (substantial (any {@self cross ? /fail /caused_by ?enter-room})))
           (effects
             (expect (or (substantial (any {@self go-to|wander ? /succ /caused_by ?enter-room}))
                         (substantial (any {@self go-to|cross ? /fail /caused_by ?enter-room})))
                     "enter-room: a door on the way and none he can cross, untried")
             (set-outcome ?enter-room /fail))))
    (try (role @self (enter-room-walked-blind ?room ?enter-room)
           (effects (set-outcome ?enter-room /fail))))
    (try (when (enter-room-walk-spot ?room): ?spot (is-spot ?spot))
         (effects (maintain-proposal {@self WALK ?spot})))))
