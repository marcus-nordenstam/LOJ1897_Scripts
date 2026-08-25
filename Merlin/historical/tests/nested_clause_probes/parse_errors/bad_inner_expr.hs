(npc-think bad_inner_expr
  (cooldown 1 m)
  (role @self )
  (role ?p [k human]
        {?p probe_urge @self {@self probe_hunt (any {@self gender}).target}})
  (effects (debug-print "MUST_NOT_LOAD")))
