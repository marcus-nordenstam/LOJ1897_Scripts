; ----------------------------------------------------------------------------
; exit - the twin of enter: get @self out of a structure and onto the street, through its
; threshold. He first walks onto the floor of the entry space enter would step in by (the
; main entrance, else any entrance, else the nearest room), then out to a spot before the
; building. Standing in it already, the first stage falls through.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

; STILL IN IT, written once and read twice: as the condition the task runs under, and in
; the cease that says what stopping meant.
(define-func still-in (?bldg)
  (spatial @self building ?bldg))

(npc-task {@self exit ?bldg}:?exit
  (tar @excl [k container-structure] @object)
  (init
    (check (is-a ?bldg [k container-structure]))
    (check (grounded ?bldg))
    (check (still-in ?bldg)))
  (when (still-in ?bldg))
  (cease (if (not (still-in ?bldg)) (then (set-outcome ?exit /succ))))
  (sequence
    ; @nothing when he already stands on the threshold or the building has none; a claim
    ; that finds its floor full is @fail, and holds the stage until a spot frees.
    (stage
      (bind (entry-space ?bldg) ?entry)
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
        (maintain-proposal {@self WALK ?spot})))))
