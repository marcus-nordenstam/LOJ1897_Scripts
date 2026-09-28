; ----------------------------------------------------------------------------
; retire (action) - the ACT half of the retirement split. The go/dwell think
; half lives in thinks/retire.mc; this file holds the dwell completion that
; commits the retirement (fires the worker) AT the workplace.
; ----------------------------------------------------------------------------

(action {@self QUIT-WORK}
  (motor body legs)
  (duration (seconds 60 min))
  (effects
    (fire-self)
    (set-outcome {@self QUIT-WORK} /succ)))
