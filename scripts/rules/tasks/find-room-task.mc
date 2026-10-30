; ----------------------------------------------------------------------------
; find-room ?room ?place - come to know a room of ?place, a building or a unit: ?room itself, or
; any room of the kind ?room. He wanders ?place - every room he stands in shows him the doorways out
; of it - and knowing the room concludes it; ?place toured without it, or never got into, fails it.
; ----------------------------------------------------------------------------

; He knows ?room, or a room of the kind ?room in ?place.
(define-func find-room-known (?room ?place)
  (flip (is-kind ?room) (known-room-of ?room ?place) (placed ?room)))

(task {@self find-room ?room ?place}:?find-room
  (tar ?)
  (aux [k building|unit] @object)
  (preparatory)
  (init (check (one-premises ?place)))
  (success-cond (find-room-known ?room ?place))
  (preemptive-or
    (try (role @self (not (premises-searched ?place ?find-room))
           (effects (maintain-proposal {@self wander ?place}))))
    (try (effects (set-outcome ?find-room /fail)))))
