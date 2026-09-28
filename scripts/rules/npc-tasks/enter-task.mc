; ----------------------------------------------------------------------------
; enter ?bldg - cross the shell of a structure he has placed, from out of doors, onto a
; spot he holds inside it. Only go proposes it.
;
; FAR he approaches the structure; AT THE HULL he looks through the door, which is how a
; man learns the spaces behind it, claims a spot on the floor of its main entrance, else
; any entrance, else the nearest room - and walks onto it. A structure's spaces are one
; navmesh island reached through its door passages, so the doorway is just a path.
;
; enter can genuinely FAIL - a locked door leaves him outside - so a CLOSED structure
; matches no hull rung and the task stalls rather than lying: the locked-door / key /
; force-entry rungs plug in there.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

(define-func inside (?bldg)
  (spatial @self building ?bldg))

; The space of kind ?kind in ?bldg nearest @self that he knows and has floor free to stand
; on, or @nothing. One whose floor has no room for him - too low a storey, or full - is passed over.
(define-func nearest-standable (?bldg ?kind)
  (bind @nothing ?space)
  (bind -1.0 ?best)
  (for-each ?r (spatial ?bldg parts ?kind)
    (if (can-stand-in ?r)
      (then
        (bind (distance @self ?r) ?d)
        (if (or (< ?best 0.0) (< ?d ?best))
          (then
            (bind ?r ?space)
            (bind ?d ?best))))))
  ?space)

; Where a man steps in: the building's main entrance, else any entrance, else its nearest
; room - the first of them with floor for him. @nothing when none has.
(define-func entry-space (?bldg)
  (nearest-standable ?bldg [k entrance main-entrance]): ?main
  (nearest-standable ?bldg [k interior-space entrance]): ?way
  (cond (case (substantial ?main) ?main)
        (case (substantial ?way) ?way)
        (else (nearest-standable ?bldg [k interior-space room]))))

(define-func knows-every (?bldg ?kind)
  (>= (count (spatial ?bldg parts ?kind))
      (count (spatial ?bldg parts ?kind /env))))

(define-func knows-every-way-in (?bldg)
  (and (knows-every ?bldg [k interior-space entrance])
       (knows-every ?bldg [k interior-space room])))

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
    ; AT THE HULL: look through the door at its entrances and rooms.
    (try
      (when (poll (< (distance @self ?bldg) (near_building_m))
                  (not (knows-every-way-in ?bldg))))
      (when -{?bldg struct-status [k closed]})
      (effects
        (for-each ?way (spatial ?bldg parts [k interior-space entrance] /env)
          (observe ?way))
        (for-each ?way (spatial ?bldg parts [k interior-space room] /env)
          (observe ?way))
        (expect (knows-every-way-in ?bldg) "enter: looking through the door taught him every way in")))
    ; ...and a building with no entrance or room a man can stand in cannot be entered at all.
    (try
      (when (poll (< (distance @self ?bldg) (near_building_m))
                  (knows-every-way-in ?bldg)
                  (unsubstantial (entry-space ?bldg))))
      (when -{?bldg struct-status [k closed]})
      (effects (expect @false "enter: no entrance or room of the building has floor to stand on")))
    ; AT THE HULL, knowing its ways in: hold a spot on the floor of the entry space and walk onto it.
    (try
      (when (poll (< (distance @self ?bldg) (near_building_m))
                  (knows-every-way-in ?bldg)
                  (entry-space ?bldg): ?room
                  (substantial ?room)))
      (when -{?bldg struct-status [k closed]})
      (when (poll (stand-spot-in ?room): ?spot))
      (effects
        (check (grounded ?room))
        (check (spatial ?room building ?bldg))
        (check (is-spot ?spot))
        (check (= (spot-anchor ?spot) ?room))
        (expect (or (= (count (spatial ?bldg parts [k interior-space entrance])) 0)
                    (is-a ?room [k interior-space entrance]))
                "enter: an entrance no man can stand in - widen it in the content")
        (maintain-proposal {@self WALK ?spot})))))
