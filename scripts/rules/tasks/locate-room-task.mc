; ----------------------------------------------------------------------------
; locate-room ?building-kind ?room-kind - stand in a room of kind ?room-kind of some building of
; kind ?building-kind: the venue outings (a pub's bar-room, a church's nave). In such a building
; the room is enter-room's; not in one, he enters the nearest he knows, or finds one; a town
; that holds none, or a building enter-room finds no such room in, fails the outing.
; ----------------------------------------------------------------------------

(task {@self locate-room ?building-kind ?room-kind}:?locate-room
  (cease (if (and (stands-in-room ?room-kind) (stands-in-building ?building-kind))
             (then (set-outcome ?locate-room /succ))))
  (preemptive-or
    (try (role @self (stands-in-room ?room-kind) (stands-in-building ?building-kind)
           (effects (set-outcome ?locate-room /succ))))
    (try (role ?here (spatial @self building) (is-a ?here ?building-kind)
           (role @self -{@self enter-room ?here ?room-kind /fail /caused_by ?locate-room}
             (effects (maintain-proposal {@self enter-room ?here ?room-kind})))))
    (try (role ?here (spatial @self building) (is-a ?here ?building-kind)
           (role @self {@self enter-room ?here ?room-kind /fail /caused_by ?locate-room}
             (effects (set-outcome ?locate-room /fail)))))
    (try (role ?bldg [k building] (is-a ?bldg ?building-kind)
                     -{@self enter ?bldg /fail /caused_by ?locate-room}
                     (select (score (near @self ?bldg)) (policy roulette unknown-last))
           (effects (maintain-proposal {@self enter ?bldg}))))
    (try (role @self -{@self find-building ?building-kind ? /fail}
           (effects (maintain-proposal {@self find-building ?building-kind (current-exterior @self)}))))
    (try (effects (set-outcome ?locate-room /fail)))))
