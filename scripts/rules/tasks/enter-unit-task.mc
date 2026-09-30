; ----------------------------------------------------------------------------
; enter-unit ?unit - through ?unit's own door onto a spot inside it. Only go proposes it. Where
; he starts is the building's business: the street, when the unit's door is its front door (a
; row house), or a shared hallway, when the building has an entrance of its own that go has
; already taken him through (a block of flats). Either way the walk is one path.
;
; FAR he walks to its travel spot; AT ITS DOOR he looks through, learning the spaces behind it,
; and walks onto a spot on the floor of its entrance.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

(task {@self enter-unit ?unit}:?enter-unit
  (tar @excl [k unit] @object)
  (lint-waive env-read-outside-action)
  (init
    (check (is-a ?unit [k unit]))
    (check (grounded ?unit)))
  (cease (if (spatial @self unit ?unit) (then (set-outcome ?enter-unit /succ))))
  (and
    (try
      (when (not (< (distance @self ?unit) (near_building_m)))
            (tolerate (travel-spot (known-box ?unit))): ?spot
            (is-spot ?spot))
      (effects (maintain-proposal {@self WALK ?spot})))
    (try
      (when (< (distance @self ?unit) (near_building_m))
            (not (knows-every ?unit [k interior-space entrance])))
      (effects
        (look-through-door ?unit)
        (expect (knows-every ?unit [k interior-space entrance]) "enter-unit: looking through the door taught him every entrance")))
    (try
      (when (< (distance @self ?unit) (near_building_m))
            (knows-every ?unit [k interior-space entrance])
            (unsubstantial (entrance-space ?unit)))
      (effects (expect @false "enter-unit: no entrance of the unit has floor to stand on")))
    (try
      (when (< (distance @self ?unit) (near_building_m))
            (knows-every ?unit [k interior-space entrance])
            (entrance-space ?unit): ?way
            (substantial ?way))
      (when (poll (stand-spot-in ?way): ?spot))
      (effects
        (check (grounded ?way))
        (check (spatial ?way unit ?unit))
        (check (is-spot ?spot))
        (check (= (spot-anchor ?spot) ?way))
        (maintain-proposal {@self WALK ?spot})))))
