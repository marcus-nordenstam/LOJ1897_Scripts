; Inner tense is a structural clause-interval test: a goal clause is ongoing, so
; /pres and /ever match it and /past must not.
(npc-think probe_tense
  (cooldown 1 m)
  (role @self )
  (when (and (any {@self goal {@self probe_hunt ? /ever}})
             (any {@self goal {@self probe_hunt ? /pres}})
             (not (any {@self goal {@self probe_hunt ? /past}}))))
  (effects (debug-print "PROBE_TENSE_OK")))
