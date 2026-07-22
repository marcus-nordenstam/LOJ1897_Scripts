; ----------------------------------------------------------------------------
; race (npc-ACT lane) - a summoned competitor's leg of the club meet. The routing
; think (sporting_event_think.hs `compete`) latched {@self race_run} off the
; {@self summoned_to_meet <sport> <organiser>} the organiser told him; this body runs
; the contest FROM HIS OWN attributes and reports the outcome.
;
; PERFORMANCE is a pure self-read: his own strength / endurance / assertiveness plus
; a draw (rng-unit) - no one reads a trait off him, and he does not read anyone
; else's. The result is OBSERVABLE: he keeps the memory of competing and mints his
; score into the co-present organiser's mind (the judge reads it back to rank the
; field). If the organiser has since left, the run simply goes unrecorded.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-act race_act
  (act {@self race_run})
  (duration 30)
  (act-effects
    ; The sport + who runs it, off my own summons.
    (bind {@self summoned_to_meet ?sport ?judge})
    ; My run: own vigour + a draw, all self-reads. Clamped to a 0..1 score.
    (bind (clamp (+ 0.10
                    (* 0.35 (attr @self strength))
                    (* 0.25 (attr @self endurance))
                    (* 0.30 (attr @self assertiveness))
                    (* 0.30 (rng-unit)))
                 0 1) ?perf)
    ; The memory of competing (my own), and the OBSERVABLE result to the organiser.
    (begin-belief {@self participated_in ?sport})
    (if (co-present @self ?judge)
        (then (begin-belief ?judge {@self race_result ?perf})))
    (end-belief {@self summoned_to_meet ?sport})
    (end-act {@self race_run})))
