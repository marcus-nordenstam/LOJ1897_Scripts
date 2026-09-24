; ----------------------------------------------------------------------------
; wander ?bldg - tour every room of the building he stands in that he has not walked into
; this round. It walks each room itself, onto a spot claimed on its floor, rather than
; proposing go: wander runs under locate, which runs under go, and a go nested under a go
; would supersede its own ancestor.
;
; The round's WALK records ARE the visited memory: each one's cell is anchored on the room
; it was claimed in, and they are keyed /caused_by this wander, so they scope themselves to
; it and retire with it.
; ----------------------------------------------------------------------------


; 1 if @self has walked into ?room during the wander ?w-rel, else 0.
(define-func wander-walked-into (?room ?w-rel)
  (bind 0 ?walked)
  (for-each ?rel (every {@self WALK ? /succ /caused_by ?w-rel /ever})
    (if (= (tolerate (cell-anchor ?rel.target)) ?room)
      (then
        (bind 1 ?walked)
        (break))))
  ?walked)

(npc-task {@self wander ?bldg}:?w-rel
  (tar @excl [k container-structure] @object)
  (init
    (check (is-a ?bldg [k container-structure]))
    (check (spatial @self building ?bldg)))
  (and
    ; Standing in the building he looks along its rooms: a room he has not yet seen from
    ; inside has no mental twin, and it cannot be walked into until it has one.
    (try
      (when (poll (< (count (spatial ?bldg parts [k interior-space room]))
                     (count (spatial ?bldg parts [k interior-space room] /env)))))
      (effects
        (for-each ?r (spatial ?bldg parts [k interior-space room] /env)
          (observe ?r))))
    (try
      (role ?room (spatial ?bldg parts [k interior-space room])
                  (not (spatial @self space ?room))
                  (= (wander-walked-into ?room ?w-rel) 0)
                  (select (score (near @self ?room)) (policy roulette))
        (when (poll (stand-cell-in ?room): ?cell))
        (effects
          (check (grounded ?room))
          (check (spatial ?room building ?bldg))
          (check (is-rel-cell ?cell))
          (check (= (cell-anchor ?cell) ?room))
          (expect (spatial @self building ?bldg) "wander: touring a building he is not in")
          (maintain-proposal {@self WALK ?cell}))))
    ; Every room but the one he started in has been walked -> the building is seen.
    (try
      (when (>= (count (every {@self WALK ? /succ /caused_by ?w-rel /ever}))
                (- (count (spatial ?bldg parts [k interior-space room] /env)) 1)))
      (effects (set-outcome ?w-rel /succ)))))
