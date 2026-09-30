; ----------------------------------------------------------------------------
; exit-unit ?unit - out of ?unit through its own door, into whatever lies past it: a room the
; unit does not hold - the landing of a block of flats - or, with none, the street, the door
; being the unit's front door (a row house). Knowing no entrance of the unit, he tours it once; a
; tour that shows none means it has none.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

; The room past ?unit's door ?way that the unit does not hold - the hallway its units share -
; or @nothing while he knows of none.
(define-func shared-room-past (?unit ?way)
  (bind @nothing ?past)
  (for-each ?beyond (spatial ?way neighbours)
    (if (and (unsubstantial ?past) (not (within-place ?beyond ?unit)))
      (then (bind ?beyond ?past))))
  ?past)

(task {@self exit-unit ?unit}:?exit-unit
  (tar @excl [k unit] @object)
  (lint-waive env-read-outside-action)
  (init
    (check (is-a ?unit [k unit]))
    (check (grounded ?unit))
    (check (spatial @self unit ?unit)))
  (cease (if (not (spatial @self unit ?unit)) (then (set-outcome ?exit-unit /succ))))
  (stable-or
    (try
      (when (empty (spatial ?unit parts [k interior-space entrance]))
            -{@self wander ?unit /succ /caused_by ?exit-unit})
      (effects (maintain-proposal {@self wander ?unit})))

    (sequence
      ; A unit toured without an entrance has none, and he steps straight out; one whose
      ; entrance has no floor free for him holds the stage until a spot frees.
      (stage
        (bind (entrance-space ?unit) ?entry)
        (when (or (substantial ?entry) (empty (spatial ?unit parts [k interior-space entrance]))))
        (bind (cond (case (unsubstantial ?entry) @nothing)
                    (case (spatial @self space ?entry) @nothing)
                    (else (stand-spot-in ?entry)))
              ?step)
        (effects
          (if (is-spot ?step)
              (then (maintain-proposal {@self WALK ?step})))))

      (stage
        (bind (spatial @self building) ?bldg)
        (bind (shared-room-past ?unit ?entry) ?past)
        (bind (if (substantial ?past)
                  (then (stand-spot-in ?past))
                  (else (maintain-claim-spot @self [/in_front_of ?bldg] [/at_or_near @self])))
              ?spot)
        (effects
          (check (is-spot ?spot))
          (maintain-proposal {@self WALK ?spot}))))))
