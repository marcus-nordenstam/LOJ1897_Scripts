; A SECOND concurrent probe_hunt goal (focus = @self as a dummy prey): the goal
; gate must FAN OUT one activation per matching goal, so PROBE_GOAL_CAP fires
; twice per NPC (once per goal), each with its own ?g11 / ?prey11 binds.
(npc-think probe_mint2
  (cooldown 1 m)
  (role @self )
  (when (and {@self goal {@self probe_hunt ?}}
             -{@self goal {@self probe_hunt @self}}))
  (effects (begin-goal {@self probe_hunt @self})))
