; ----------------------------------------------------------------------------
; enter ?bldg - cross the shell of a structure he has placed, from out of doors, onto a
; spot he holds in a room inside it. Only go proposes it.
;
; FAR he approaches the structure; AT THE HULL he looks through the door, which is how a
; man learns the room behind it, claims a cell on the floor of the nearest room he now
; knows, and walks onto it. A structure's rooms are one navmesh island reached through its
; door passages, so the doorway is just a path.
;
; enter can genuinely FAIL - a locked door leaves him outside - so a CLOSED structure
; matches no hull rung and the task stalls rather than lying: the locked-door / key /
; force-entry rungs plug in there.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

(define-func inside (?bldg)
  (spatial @self building ?bldg))

; The room of ?bldg nearest @self that he knows and has floor free to stand on, or @nothing.
; A room whose floor holds no person-sized cell - too low a storey, or full - is passed over.
(define-func nearest-standable-room (?bldg)
  (bind @nothing ?room)
  (bind -1.0 ?best)
  (for-each ?r (spatial ?bldg parts [k interior-space room])
    (if (can-stand-in ?r)
      (then
        (bind (distance @self ?r) ?d)
        (if (or (< ?best 0.0) (< ?d ?best))
          (then
            (bind ?r ?room)
            (bind ?d ?best))))))
  ?room)

(define-func knows-every-room (?bldg)
  (>= (count (spatial ?bldg parts [k interior-space room]))
      (count (spatial ?bldg parts [k interior-space room] /env))))

(npc-task {@self enter ?bldg}:?enter-rel
  (tar @excl [k container-structure] @object)
  ; The rooms behind the door are read from ground truth at the hull: standing before a
  ; building is how a man learns what is behind its door.
  (lint-waive env-read-outside-action)
  (init
    (check (is-a ?bldg [k container-structure]))
    (check (grounded ?bldg))
    (check (unsubstantial (spatial @self building))))
  (when (not (inside ?bldg)))
  (cease (if (inside ?bldg) (then (set-outcome ?enter-rel /succ))))
  (and
    (try
      (when (poll (not (< (distance @self ?bldg) (near_building_m)))))
      (effects
        (check (grounded ?bldg))
        (maintain-proposal {@self approach ?bldg})))
    ; AT THE HULL, knowing no room of it he can stand in: look through the door at them all.
    (try
      (when (poll (< (distance @self ?bldg) (near_building_m))
                  (unsubstantial (nearest-standable-room ?bldg))
                  (not (knows-every-room ?bldg))))
      (when -{?bldg struct-status [k closed]})
      (effects
        (for-each ?way (spatial ?bldg parts [k interior-space room] /env)
          (observe ?way))
        (expect (knows-every-room ?bldg) "enter: looking through the door taught him every room")))
    ; ...and a building with no room a man can stand in cannot be entered at all.
    (try
      (when (poll (< (distance @self ?bldg) (near_building_m))
                  (unsubstantial (nearest-standable-room ?bldg))
                  (knows-every-room ?bldg)))
      (when -{?bldg struct-status [k closed]})
      (effects (expect @false "enter: no room of the building has floor to stand on")))
    ; AT THE HULL, knowing a room: hold a spot on its floor and walk onto it.
    (try
      (when (poll (< (distance @self ?bldg) (near_building_m))
                  (nearest-standable-room ?bldg): ?room
                  (substantial ?room)))
      (when -{?bldg struct-status [k closed]})
      (when (poll (stand-cell-in ?room): ?cell))
      (effects
        (check (grounded ?room))
        (check (spatial ?room building ?bldg))
        (check (is-rel-cell ?cell))
        (check (= (cell-anchor ?cell) ?room))
        (maintain-proposal {@self WALK ?cell})))))
