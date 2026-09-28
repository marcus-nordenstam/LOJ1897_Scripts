; Nested bind with capture: the inner free var and the whole-clause capture bind.
(npc-think probe_bind
  (cooldown 1 m try-once)
  (role @self 
    (when (bind {@self goal {@self probe_hunt ?prey2}:?probe_hunt}))
    (effects (debug-print "PROBE_BIND prey=?prey2 plot=?probe_hunt"))))
