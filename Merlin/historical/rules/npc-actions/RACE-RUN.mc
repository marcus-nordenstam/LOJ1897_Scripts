; ----------------------------------------------------------------------------
; race (npc-ACT lane) - a summoned competitor's leg of the club meet. The routing
; think (sporting_event_think.hs `compete`) latched {@self RACE-RUN} off the
; {<organiser> summon @self /aux <sport>} ticket the organiser told him; this body runs
; the contest FROM HIS OWN attributes and reports the outcome.
;
; PERFORMANCE is a pure self-read: his own strength / endurance / assertiveness plus
; a draw (rng-unit) - no one reads a trait off him, and he does not read anyone
; else's. The result is OBSERVABLE: he keeps the memory of competing and mints his
; score into the co-present organiser's mind (the judge reads it back to rank the
; field). If the organiser has since left, the run simply goes unrecorded.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")

; The run: the sport + the judging organiser arrive ON the action pattern
; (compete reads the summons and passes them); the body reads only its own
; physiology - the physics of the run - and writes the records.
(npc-action {@self RACE-RUN ?sport ?judge}
  (track-skill-level [k athletics])
  (duration 30)
  (effects
    ; My run: own vigour + a draw, all self-reads. Clamped to a 0..1 score.
    (clamp (+ 0.10
                    (* 0.35 (attr @self strength))
                    (* 0.25 (attr @self endurance))
                    (* 0.30 (attr @self assertiveness))
                    (* 0.30 (rng-unit)))
                 0 1): ?perf
    ; The OBSERVABLE result to the organiser (the ended race_run act-belief is
    ; my own memory of competing); aux carries the sport so the judge's
    ; declaration knows which contest the score belongs to.
    (if (spatial ?judge co-located @self)
        (then (begin-belief ?judge {@self race-result ?perf ?sport})))
    (end-belief {?judge summon @self ?sport})
    (set-outcome {@self RACE-RUN ?sport ?judge} /succ)))
