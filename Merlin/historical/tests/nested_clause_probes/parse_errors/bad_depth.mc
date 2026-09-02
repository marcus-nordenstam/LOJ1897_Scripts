(npc-think bad_depth
  (cooldown 1 m)
  (role @self )
  (when (believes {@self a {@self b {@self c {@self d {@self e {@self f ?}}}}}}))
  (effects (debug-print "MUST_NOT_LOAD")))
