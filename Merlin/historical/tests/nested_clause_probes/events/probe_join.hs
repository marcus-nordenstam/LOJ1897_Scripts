; Join-routing probe: the inner clause target names the sibling role ?prey7, so
; the filter must route to join_filters (load proof; the A-object is tested by
; the join matcher at materialization).
(npc-think probe_join
  (cooldown 1 m)
  (role @self )
  (role ?prey7 [k human] (select (policy first-match)))
  (role ?plotter7 [k human]
        {?plotter7 urge @self {@self probe_hunt ?prey7}})
  (effects (debug-print "PROBE_JOIN plotter=?plotter7 prey=?prey7")))
