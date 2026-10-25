; ----------------------------------------------------------------------------
; RACE-RUN ?sport ?judge - a competitor's leg of the club meet, run for the judging
; organiser. PERFORMANCE is a pure self-read: his own strength / endurance / assertiveness
; plus a draw (rng-unit) - no one reads a trait off him, and he reads no one else's. He
; comes away with his own result ({@self race-result <score> <sport>}); the organiser learns
; it the way anyone learns another man's result, by being told it.
; ----------------------------------------------------------------------------

(action {@self RACE-RUN ?sport ?judge}:?RACE-RUN
  (motor legs)
  (track-skill-level [k athletics])
  (duration (seconds 30 min))
  (effects
    (clamp (+ 0.10
              (* 0.35 (attr @self strength))
              (* 0.25 (attr @self endurance))
              (* 0.30 (attr @self assertiveness))
              (* 0.30 (rng-unit)))
           0.0 1.0): ?perf
    (begin-belief {@self race-result ?perf ?sport})
    (set-outcome ?RACE-RUN /succ)))
