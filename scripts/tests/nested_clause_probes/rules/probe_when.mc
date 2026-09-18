; Nested existence in (when): full structural inner match (subject + label).
(npc-think probe_when
  (cooldown 1 m)
  (role @self )
  (when {@self goal {@self probe_hunt ?}})
  (effects (debug-print "PROBE_WHEN_EXISTS")))
