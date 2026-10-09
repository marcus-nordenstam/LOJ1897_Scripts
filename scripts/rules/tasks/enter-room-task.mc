; ----------------------------------------------------------------------------
; enter-room ?place ?room-kind - stand in a room of kind ?room-kind of ?place, a concrete
; building or unit (go-to-bed hands his home; locate-room hands the venue it found). He enters a
; room of the kind he knows, or locates one; a place he finds none in fails the outing.
; ----------------------------------------------------------------------------

(task {@self enter-room ?place ?room-kind}:?enter-room
  (tar @excl [k building|unit] @object)
  (cease (if (and (stands-in-room ?room-kind) (within-place @self ?place))
             (then (set-outcome ?enter-room /succ))))
  (preemptive-or
    (try (role @self (stands-in-room ?room-kind) (within-place @self ?place)
           (effects (set-outcome ?enter-room /succ))))
    (try (role ?room (spatial ?place rooms) (is-a ?room ?room-kind)
                     (select (score (near @self ?room)) (policy roulette unknown-last))
           (effects (maintain-proposal {@self go-to ?room}))))
    (try (role @self -{@self locate ?room-kind ?place /fail}
           (effects (maintain-proposal {@self locate ?room-kind ?place}))))
    (try (effects (set-outcome ?enter-room /fail)))))
