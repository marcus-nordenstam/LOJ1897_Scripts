; ----------------------------------------------------------------------------
; exit-building ?bldg - the twin of enter-building: from a space ?bldg's units share, or a
; unit-less building's own, out through an entrance the building holds itself and onto a spot
; before it. Knowing no entrance of it, he tours it once; a tour that shows none means it has
; none. Knowing one, he walks onto its floor, opens its door when he believes it shut, then goes
; out; standing in it already, or with no entrance to take, that first stage falls through, and
; a door he believes locked holds him inside.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

(task {@self exit-building ?bldg}:?exit-building
  (tar @excl [k building] @object)
  (init
    (check (is-a ?bldg [k building]))
    (check (grounded ?bldg))
    (check (spatial @self building ?bldg)))
  (cease (if (not (spatial @self building ?bldg)) (then (set-outcome ?exit-building /succ))))
  (stable-or
    (try
      (when (empty (spatial ?bldg parts [k entrance]))
            -{@self wander ?bldg /succ /caused_by ?exit-building})
      (effects (maintain-proposal {@self wander ?bldg})))

    (sequence
      (stage
        (bind (entrance-space ?bldg) ?entry)
        (when (or (substantial ?entry) (empty (spatial ?bldg parts [k entrance]))))
        (bind (cond (case (unsubstantial ?entry) @nothing)
                    (case (spatial @self space ?entry) @nothing)
                    (else (stand-spot-in ?entry)))
              ?step)
        (effects
          (if (is-spot ?step)
              (then (maintain-proposal {@self WALK ?step})))))

      (stage
        (bind (if (substantial ?entry) (then (barrier-of ?bldg ?entry)) (else @nothing)) ?barrier)
        (when (not (barred-locked ?barrier)))
        (effects
          (if (barred ?barrier)
              (then (maintain-proposal {@self open-barrier ?barrier})))))

      (stage
        (bind (maintain-claim-spot @self [/in_front_of ?bldg] [/at_or_near @self]) ?spot)
        (effects
          (check (is-spot ?spot))
          (check (not (overlaps ?spot ?bldg)))
          (maintain-proposal {@self WALK ?spot}))))))
