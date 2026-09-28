; DIE - dying of ?cause: the body falls, (die) writes its condition dead, and the corpse
; carries its cause.

(action {@self DIE ?cause}:?DIE
  (duration 1.5)
  (motor legs)
  (obs)
  (tar [k death-cause] @excl)
  (presentation
    (preroll 0.0) (in 0.2) (out 0.0))
  (effects
    (set-outcome ?DIE /succ)
    (set-attr @self death-cause ?cause)
    (die @self)))
