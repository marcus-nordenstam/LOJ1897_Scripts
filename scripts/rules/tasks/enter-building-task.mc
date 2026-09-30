; ----------------------------------------------------------------------------
; enter-building ?bldg - from out of doors, through an entrance ?bldg holds itself - the one its
; units share, or a unit-less building's own - onto a spot inside. Only go proposes it; a
; building of units with no shared entrance is entered unit by unit (enter-unit).
;
; FAR he walks to its travel spot; AT THE HULL he looks through the door, which is how a man
; learns the spaces behind it, and walks onto a spot on the floor of its entrance, else its
; nearest room. A CLOSED building matches no hull rung and the task stalls rather than lying:
; the locked-door / key / force-entry rungs plug in there.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

(task {@self enter-building ?bldg}:?enter-building
  (tar @excl [k building] @object)
  ; What is behind the door is read from ground truth at the hull: standing before a building
  ; is how a man learns it.
  (lint-waive env-read-outside-action)
  (init
    (check (is-a ?bldg [k building]))
    (check (grounded ?bldg))
    (check (unsubstantial (spatial @self building))))
  (cease (if (spatial @self building ?bldg) (then (set-outcome ?enter-building /succ))))
  (and
    (try
      (when (not (< (distance @self ?bldg) (near_building_m)))
            (tolerate (travel-spot (known-box ?bldg))): ?spot
            (is-spot ?spot))
      (effects (maintain-proposal {@self WALK ?spot})))
    (try
      (when (< (distance @self ?bldg) (near_building_m))
            (not (knows-every-way-in ?bldg)))
      (when -{?bldg struct-status [k closed]})
      (effects
        (look-through-door ?bldg)
        (expect (knows-every-way-in ?bldg) "enter-building: looking through the door taught him every way in")))
    (try
      (when (< (distance @self ?bldg) (near_building_m))
            (knows-every-way-in ?bldg)
            (unsubstantial (entry-space ?bldg)))
      (when -{?bldg struct-status [k closed]})
      (effects (expect @false "enter-building: no entrance or room of its own has floor to stand on")))
    (try
      (when (< (distance @self ?bldg) (near_building_m))
            (knows-every-way-in ?bldg)
            (entry-space ?bldg): ?way
            (substantial ?way))
      (when -{?bldg struct-status [k closed]})
      (when (poll (stand-spot-in ?way): ?spot))
      (effects
        (check (grounded ?way))
        (check (spatial ?way building ?bldg))
        (check (is-spot ?spot))
        (check (= (spot-anchor ?spot) ?way))
        (maintain-proposal {@self WALK ?spot})))))
