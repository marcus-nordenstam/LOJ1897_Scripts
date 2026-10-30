; ----------------------------------------------------------------------------
; enter-room-kind ?kind ?bldg - stand INSIDE a room of kind ?kind in ?bldg, a building or a unit (his
; home's bedroom), or in any building of the kind ?bldg (a pub's bar-room, a church's nave).
;
; It requires that he knows a room of the kind in ?bldg (knows-room-of) and a building of the kind
; ?bldg (knows-building-of): the finds fill them. In ?bldg he enters the nearest room of the kind he
; knows there; of a building kind, he looks in the one he stands in, else in the nearest he knows.
; Every one failing fails it. Done when he stands in such a room and no enter of this one still runs.
; ----------------------------------------------------------------------------

; In a room of ?kind in ?bldg, with no enter of this one still running.
(define-func enter-room-kind-done (?kind ?bldg ?enter-room-kind)
  (and (stands-in-room ?kind)
       (flip (is-kind ?bldg) (stands-in-building ?bldg) (within-place @self ?bldg))
       (unsubstantial (any {@self enter-room ? /caused_by ?enter-room-kind}))
       (unsubstantial (any {@self enter-room-kind ? ? /caused_by ?enter-room-kind}))))

(task {@self enter-room-kind ?kind ?bldg}:?enter-room-kind
  (tar ?)
  (aux ?)
  (requires (knows-room-of ?kind ?bldg) (knows-building-of ?bldg))
  (init (check (is-kind ?kind)))
  (success-cond (enter-room-kind-done ?kind ?bldg ?enter-room-kind))
  (preemptive-or
    (try (role @self (is-object ?bldg)
           (role ?room (spatial ?bldg rooms) (is-a ?room ?kind)
                       -{@self enter-room ?room /fail /caused_by ?enter-room-kind}
                       (select (score (near @self ?room)) (policy roulette unknown-last))
             (effects (maintain-proposal {@self enter-room ?room})))))
    (try (role @self (is-kind ?bldg)
           (role ?here (spatial @self building) (is-a ?here ?bldg)
                       -{@self enter-room-kind ?kind ?here /fail /caused_by ?enter-room-kind}
             (effects (maintain-proposal {@self enter-room-kind ?kind ?here})))))
    (try (role @self (is-kind ?bldg)
           (role ?building [k building] (is-a ?building ?bldg)
                           -{@self enter-room-kind ?kind ?building /fail /caused_by ?enter-room-kind}
                           (select (score (near @self ?building)) (policy roulette unknown-last))
             (effects (maintain-proposal {@self enter-room-kind ?kind ?building})))))
    (try (effects (set-outcome ?enter-room-kind /fail)))))
