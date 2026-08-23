; Residual/ordering probe: filter 1 produces ?prey6 from INSIDE the clause at the
; gate; filter 2 consumes it as a top-level constraint. Fires only when both agree.
(npc-think probe_residual
  (cooldown 1 m)
  (role @self )
  (role ?plotter6 [k human]
        {?plotter6 urge @self {@self probe_hunt ?prey6}}
        {?plotter6 accomplice ?prey6})
  (effects (debug-print "PROBE_RESIDUAL plotter=?plotter6 prey=?prey6")))
