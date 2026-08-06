(npc-think bad_fanout
  (cooldown 1 m)
  (role @self )
  (when (believes {@self goal {@self probe_hunt (fan-out ?x)}}))
  (effects (debug-print "MUST_NOT_LOAD")))
