; ----------------------------------------------------------------------------
; enter-room-kind ?kind ?bldg - stand INSIDE a room of kind ?kind in ?bldg, a building or a unit (his
; home's bedroom), or in any building of the kind ?bldg (a pub's bar-room, a church's nave).
;
; Its preconditions are that he knows a room of the kind in ?bldg (knows-room-of) and a building of the kind
; ?bldg (knows-building-of): the finds achieve them. In ?bldg he enters the nearest room of the kind he
; knows there; of a building kind, he looks in the nearest he knows - the one he stands in, if any.
; Every one failing fails it. Done when he stands in such a room and no enter of this one still runs.
; ----------------------------------------------------------------------------

; In a room of ?kind in ?bldg, with no enter of this one still running.
(define-func enter-room-kind-done (?kind ?bldg ?enter-room-kind)
  (and (stands-in-room-of ?kind ?bldg)
       (unsubstantial (any {@self enter-room ? /caused_by ?enter-room-kind}))
       (unsubstantial (any {@self enter-room-kind ? ? /caused_by ?enter-room-kind}))))

(task {@self enter-room-kind ?kind ?bldg}:?enter-room-kind
  (tar ?)
  (aux ?)
  (preconditions (knows-room-of ?kind ?bldg) (knows-building-of ?bldg))
  (init (check (is-kind ?kind)))
  (success-cond (enter-room-kind-done ?kind ?bldg ?enter-room-kind))
  (preemptive-or
    (try (role @self (is-object ?bldg)
           (role ?room (spatial ?bldg rooms) (is-a ?room ?kind)
                       -{@self enter-room ?room /fail /caused_by ?enter-room-kind}
                       (select (score (near @self ?room)) (policy roulette unknown-last))
             (effects (maintain-proposal {@self enter-room ?room} /tolerate-fail)))))
    (try (role @self (is-kind ?bldg)
           (role ?building [k building] (is-a ?building ?bldg)
                           -{@self enter-room-kind ?kind ?building /fail /caused_by ?enter-room-kind}
                           (select (score (near @self ?building)) (policy argmax unknown-last))
             (effects (maintain-proposal {@self enter-room-kind ?kind ?building} /tolerate-fail)))))
    (try (effects (set-outcome ?enter-room-kind /fail)))))
