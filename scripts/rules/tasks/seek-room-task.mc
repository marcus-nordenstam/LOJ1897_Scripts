; ----------------------------------------------------------------------------
; seek-room ?building-kind ?room-kind - stand in a room of kind ?room-kind of some building of
; kind ?building-kind: the venue outings (a pub's bar-room, a church's nave). In such a building
; the room is enter-room's; not in one, he enters the nearest he knows, or finds one; a town
; that holds none, or a building enter-room finds no such room in, fails the outing.
; ----------------------------------------------------------------------------

(task {@self seek-room ?building-kind ?room-kind}:?seek-room
  (cease (if (and (stands-in-room ?room-kind) (stands-in-building ?building-kind))
             (then (set-outcome ?seek-room /succ))))
  (preemptive-or
    (try (role @self (stands-in-room ?room-kind) (stands-in-building ?building-kind)
           (effects (set-outcome ?seek-room /succ))))
    (try (role ?here (spatial @self building) (is-a ?here ?building-kind)
           (role @self -{@self enter-room ?here ?room-kind /fail /caused_by ?seek-room}
             (effects (maintain-proposal {@self enter-room ?here ?room-kind})))))
    (try (role ?here (spatial @self building) (is-a ?here ?building-kind)
           (role @self {@self enter-room ?here ?room-kind /fail /caused_by ?seek-room}
             (effects (set-outcome ?seek-room /fail)))))
    (try (role ?bldg [k building] (is-a ?bldg ?building-kind)
                     -{@self enter ?bldg /fail /caused_by ?seek-room}
                     (select (score (near @self ?bldg)) (policy roulette unknown-last))
           (effects (maintain-proposal {@self enter ?bldg}))))
    (try (role @self -{@self find-building ?building-kind ? /fail}
           (effects (maintain-proposal {@self find-building ?building-kind (current-exterior @self)}))))
    (try (when @true)
         (effects (set-outcome ?seek-room /fail)))))
