; GATE-VAR SUBJECT probe: the (goal ...) gate binds ?prey; the self-gate residual
; tests a belief whose SUBJECT is that gate var - {?prey accomplice ?acc}. Residual
; placement seeds the (goal ...)/(task ...) gate vars, so a gate-var subject is
; PLACEABLE (threaded live at the when-gate seam) rather than a hard load error.
; Fires once per NPC holding the mint's goal + the {?prey accomplice ?prey} belief.
(npc-think probe_gatevar
  (cooldown 1 m)
  (goal {@self probe_hunt ?prey})
  (role @self {?prey accomplice ?acc})
  (effects (debug-print "PROBE_GATEVAR prey=?prey acc=?acc")))
