; DIE - dying of ?cause: the body falls, the world is settled (settle-death), and the
; corpse carries its cause.

(npc-action {@self DIE ?cause}:?die-rel
  (duration 1.5)
  (motor legs)
  (obs)
  (tar [k death-cause] @excl)
  (presentation
    (preroll 0.0) (in 0.2) (out 0.0))
  (effects
    (set-outcome ?die-rel /succ)
    (set-attr @self death-cause ?cause)
    (settle-death @self)))
