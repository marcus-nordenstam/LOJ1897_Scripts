; THE Part 3 probe: a nested clause criterion in an ENUMERATED role filter. The
; rule must wake on probe_mint's urge-belief write (outer-label trigger), admit
; the plotter via alpha clause descent, and bind the inner free var + capture at
; the when-gate.
(npc-think probe_role
  (cooldown 1 m)
  (role @self )
  (role ?plotter [k human]
        {?plotter urge @self {@self probe_hunt ?prey3}:?plot3})
  (effects (debug-print "PROBE_ROLE plotter=?plotter prey=?prey3 plot=?plot3")))
