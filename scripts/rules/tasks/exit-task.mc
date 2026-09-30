; ----------------------------------------------------------------------------
; exit - the twin of enter: get @self out of a structure and onto the street, through its
; entrance. Knowing no entrance of it, he tours it once; a tour that shows none means it has
; none. Knowing one, he walks onto its floor, then out to a spot before the building;
; standing in it already, or with no entrance to take, that first stage falls through.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

; STILL IN IT, written once and read twice: as the condition the task runs under, and in
; the cease that says what stopping meant.
(define-func still-in (?bldg)
  (spatial @self building ?bldg))

(task {@self exit ?bldg}:?exit
  (tar @excl [k building] @object)
  (init
    (check (is-a ?bldg [k building]))
    (check (grounded ?bldg))
    (check (still-in ?bldg)))
  (when (still-in ?bldg))
  (cease (if (not (still-in ?bldg)) (then (set-outcome ?exit /succ))))
  (stable-or
    (try
      (when (empty (spatial ?bldg parts [k interior-space entrance]))
            -{@self wander ?bldg /succ /caused_by ?exit})
      (effects (maintain-proposal {@self wander ?bldg})))

    (sequence
      ; A building toured without an entrance has none, and he steps straight out; one whose
      ; entrance has no floor free for him holds the stage until a spot frees.
      (stage
        (bind (entrance-space ?bldg) ?entry)
        (when (or (substantial ?entry) (empty (spatial ?bldg parts [k interior-space entrance]))))
        (bind (cond (case (unsubstantial ?entry) @nothing)
                    (case (spatial @self space ?entry) @nothing)
                    (else (stand-spot-in ?entry)))
              ?step)
        (effects
          (if (is-spot ?step)
              (then (maintain-proposal {@self WALK ?step})))))

      (stage
        (bind (maintain-claim-spot @self [/in_front_of ?bldg] [/at_or_near @self]) ?spot)
        (effects
          (check (is-spot ?spot))
          (check (not (overlaps ?spot ?bldg)))
          (maintain-proposal {@self WALK ?spot}))))))
