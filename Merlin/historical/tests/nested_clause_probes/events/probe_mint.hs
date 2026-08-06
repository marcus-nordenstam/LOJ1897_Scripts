; Stage the nested-clause probe state: mint a goal (whose inner clause the other
; probes match), then re-bind its clause and mint an urge-shaped candidate-subject
; belief carrying that clause, plus a pledge belief for the residual-ordering probe.
(npc-think probe_mint
  (cooldown 1 m)
  (role @self )
  (role ?prey [k human] (select (policy first-match)))
  (when (not (believes {@self goal {@self probe_hunt ?}})))
  (effects
    (begin-goal {@self probe_hunt ?prey})
    (bind {@self goal {@self probe_hunt ?p2}:?plot})
    (begin-belief {?prey urge @self ?plot})
    (begin-belief {?prey accomplice ?prey})
    (debug-print "PROBE_MINT prey=?prey plot=?plot")))
