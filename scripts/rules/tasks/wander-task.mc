; ----------------------------------------------------------------------------
; wander ?place - tour every room ?place holds, a unit or a unit-less building, one room at a
; time. Standing in a room shows him the doorways out of it, so the rooms he knows grow as he
; goes: he walks into one he has not toured, and the tour is done when every room of ?place he
; knows has been toured. Every room is reachable from every other, so a tour that has run out of
; known rooms has seen them all.
;
; The tally is private: a room is marked toured, keyed by this wander, on the room itself, once
; the walk this wander sent him on to it has ended - arrived, or failed. Marks are per distinct
; room, so passing back through a toured room counts for nothing, and the room he starts in is
; toured by a walk that arrives at once. A mark names the wander that made it, so the next
; wander reads an old mark as untoured and writes over it.
; ----------------------------------------------------------------------------

; Every room of ?place that @self knows has been toured by ?wander.
(define-func toured-all (?place ?wander)
  (bind @nothing ?untoured)
  (for-each ?room (spatial ?place parts [k interior-space room])
    (if (bb-none ?room toured ?wander)
      (then
        (bind ?room ?untoured)
        (break))))
  (unsubstantial ?untoured))

(task {@self wander ?place}:?wander
  (tar @excl [k building|unit] @object)
  (init
    (check (or (is-a ?place [k building]) (is-a ?place [k unit])))
    (check (within-place @self ?place)))
  (and
    ; A room he knows and has not toured: he walks into it.
    (try
      (role ?room (spatial ?place parts [k interior-space room])
                  (bb-none ?room toured ?wander)
                  -{@self go ?room /succ /caused_by ?wander}
                  -{@self go ?room /fail /caused_by ?wander}
                  (select (score (near @self ?room)) (policy roulette unknown-first))
        (effects
          (check (grounded ?room))
          (maintain-proposal {@self go ?room}))))
    ; The walk arrived: the room is toured.
    (try
      (role ?room (spatial ?place parts [k interior-space room])
                  {@self go ?room /succ /caused_by ?wander}
                  (bb-none ?room toured ?wander)
        (effects (bb-write ?room toured ?wander))))
    ; The walk failed: the room is toured as far as it ever will be.
    (try
      (role ?room (spatial ?place parts [k interior-space room])
                  {@self go ?room /fail /caused_by ?wander}
                  (bb-none ?room toured ?wander)
        (effects (bb-write ?room toured ?wander))))
    (try
      (when (toured-all ?place ?wander))
      (effects (set-outcome ?wander /succ)))))
