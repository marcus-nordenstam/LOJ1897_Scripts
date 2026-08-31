(npc-think bad_both_gates
  (goal {@self probe_hunt ?p})
  (task {@self enter ?s})
  (effects (debug-print "MUST_NOT_LOAD")))
