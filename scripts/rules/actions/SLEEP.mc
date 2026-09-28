; ----------------------------------------------------------------------------
; SLEEP (action) - the sleep act of the FATIGUE / REST aspect, proposed by go-to-bed
; (tasks/go-to-bed-task.mc) in a bedroom.
; ----------------------------------------------------------------------------

; The act computes its NATURAL duration from the sleeper's own body (sleep-duration-min,
; funcs/physiology.mc): the debt left and his body clock - no schedule, no beliefs. A sleep
; begun in the evening ends the NEXT MORNING, and a window simulates one day: crossing out of it
; is proper to sleeping, not a mistake, so the window-exit pass concludes this act at the hour
; its duration gave it rather than cutting it off at midnight.
(action {@self SLEEP}
  (motor all)
  (init (set-attr @self awareness [k asleep]))
  (cease (set-attr @self awareness [k awake]))
  (presentation
    (preroll 0.0) (in 0.0) (out 0.0))
  (succeed-on-window-exit)
  (duration (seconds (floor (sleep-duration-min)) min))
  (effects (set-outcome {@self SLEEP} /succ)))
