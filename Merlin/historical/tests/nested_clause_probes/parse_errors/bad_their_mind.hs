(npc-think bad_their_mind
  (cooldown 1 m)
  (role @self )
  (when (believes {@self goal {@self probe_hunt ? /their-mind}}))
  (effects (debug-print "MUST_NOT_LOAD")))
