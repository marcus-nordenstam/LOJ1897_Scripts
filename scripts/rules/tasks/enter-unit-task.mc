; ----------------------------------------------------------------------------
; enter-unit ?unit - through ?unit's own door onto a spot inside it. Only go proposes it. Where
; he starts is the building's business: the street, when the unit's door is its front door (a
; row house), or a shared hallway, when the building has an entrance of its own that go has
; already taken him through (a block of flats). Either way the walk is one path.
;
; FAR he walks to its travel spot; AT ITS DOOR he looks through, learning the spaces behind it,
; and walks onto a spot on the floor of its entrance, else its nearest room.
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
            (not (knows-every-way-in ?unit)))
      (effects
        (look-through-door ?unit)
        (expect (knows-every-way-in ?unit) "enter-unit: looking through the door taught him every way in")))
    (try
      (when (< (distance @self ?unit) (near_building_m))
            (knows-every-way-in ?unit)
            (unsubstantial (entry-space ?unit)))
      (effects (expect @false "enter-unit: no entrance or room of the unit has floor to stand on")))
    (try
      (when (< (distance @self ?unit) (near_building_m))
            (knows-every-way-in ?unit)
            (entry-space ?unit): ?way
            (substantial ?way))
      (when (poll (stand-spot-in ?way): ?spot))
      (effects
        (check (grounded ?way))
        (check (spatial ?way unit ?unit))
        (check (is-spot ?spot))
        (check (= (spot-anchor ?spot) ?way))
        (maintain-proposal {@self WALK ?spot})))))
