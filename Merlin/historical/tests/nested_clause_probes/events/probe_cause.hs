; Ops return values: (bind (begin-belief {..}) ?bond) captures the committed
; belief SYMBOL, and /caused_by ?bond pins it on the minted goal by identity - the
; handle-form provenance that replaces re-derived /caused_by {pattern} pins.
(npc-think probe_cause
  (cooldown 1 m)
  (role @self )
  (role ?prey9 [k human] (select (policy first-match)))
  (when (and (believes {@self goal {@self probe_hunt ?}})
             (not (believes {@self accomplice ?prey9}))))
  (effects
    (bind (begin-belief {@self accomplice ?prey9}) ?bond)
    (begin-goal {@self kill ?prey9} /caused_by ?bond)
    (debug-print "PROBE_CAUSE bond=?bond")))
