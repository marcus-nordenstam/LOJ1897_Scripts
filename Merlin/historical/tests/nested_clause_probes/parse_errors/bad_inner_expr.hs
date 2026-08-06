(npc-think bad_inner_expr
  (cooldown 1 m)
  (role @self )
  (role ?p [k human]
        (believes {?p probe_urge @self {@self probe_hunt (target {@self gender})}}))
  (effects (debug-print "MUST_NOT_LOAD")))
