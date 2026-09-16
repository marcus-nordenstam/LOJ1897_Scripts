; Nested bind with capture: the inner free var and the whole-clause capture bind.
(npc-think probe_bind
  (cooldown 1 m)
  (role @self )
  (when (bind {@self goal {@self probe_hunt ?prey2}:?plot2}))
  (effects (debug-print "PROBE_BIND prey=?prey2 plot=?plot2")))
