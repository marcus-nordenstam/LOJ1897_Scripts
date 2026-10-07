; ----------------------------------------------------------------------------
; enter-building ?bldg - from out of doors, through an entrance ?bldg holds itself - the one its
; units share, or a unit-less building's own - onto a spot inside. Only go proposes it; a
; building of units with no shared entrance is entered unit by unit (enter-unit).
;
; FAR he walks to its travel spot; AT THE HULL he looks through the door, which is how a man
; learns the spaces behind it, opens the entrance's door when he believes it shut, and walks onto
; a spot on the floor of its entrance; a building with no entrance of its own cannot be entered.
; A CLOSED building, or an entrance whose door he believes locked, matches no hull rung and the
; task stalls rather than lying: the key / force-entry rungs plug in there.
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
            (not (knows-every ?bldg [k entrance])))
      (when -{?bldg struct-status [k closed]})
      (effects
        (look-through-door ?bldg)
        (expect (knows-every ?bldg [k entrance]) "enter-building: looking through the door taught him every entrance")))
    (try
      (when (< (distance @self ?bldg) (near_building_m))
            (knows-every ?bldg [k entrance])
            (unsubstantial (entrance-space ?bldg)))
      (when -{?bldg struct-status [k closed]})
      (effects (expect @false "enter-building: no entrance of its own has floor to stand on")))
    (try
      (when (< (distance @self ?bldg) (near_building_m))
            (knows-every ?bldg [k entrance])
            (entrance-space ?bldg): ?way
            (substantial ?way)
            (barrier-of ?bldg ?way): ?barrier
            (barred ?barrier)
            (not (barred-locked ?barrier)))
      (when -{?bldg struct-status [k closed]})
      (effects (maintain-proposal {@self open-barrier ?barrier})))
    (try
      (when (< (distance @self ?bldg) (near_building_m))
            (knows-every ?bldg [k entrance])
            (entrance-space ?bldg): ?way
            (substantial ?way)
            (not (barred (barrier-of ?bldg ?way))))
      (when -{?bldg struct-status [k closed]})
      (when (poll (stand-spot-in ?way): ?spot))
      (effects
        (check (grounded ?way))
        (check (spatial ?way building ?bldg))
        (check (is-spot ?spot))
        (check (= (spot-anchor ?spot) ?way))
        (maintain-proposal {@self WALK ?spot})))))
