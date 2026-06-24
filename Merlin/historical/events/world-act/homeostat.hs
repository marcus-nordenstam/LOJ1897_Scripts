; ----------------------------------------------------------------------------
; Population homeostat. Annual feedback loop that nudges alive-count toward
; the target carrying capacity. Two zero-role events:
;
;   homeostat_emigration: too crowded -> emigrate the oldest N
;   homeostat_immigration: too sparse -> spawn N adult immigrants
;
; Force-reconciliation (final-year hard pin) is a third event that runs at
; (one-shot end_year december). It uses the same verbs but with a target
; passed in via the cfg knob; deferred until cfg.force_survivors is exposed
; to the engine (today the homeostat target is a literal in the .hse).
;
; Both events run unconditionally each year - the (when ...) gate is what
; decides whether anything actually happens.
; ----------------------------------------------------------------------------
; The homeostat tables are auto-loaded from historical/tables/.

(hsim-event homeostat_emigration
  (nl         "homeostat: emigration wave (alive=?alive)")
  (schedule   (annually january))
  (rng-stream homeostat)

  (let ((?alive    (alive-count))
        (?target   (homeostat_target_population))
        (?pressure (/ ?alive ?target))
        (?count    (homeostat_emigration_count)))

    (when (> ?pressure (homeostat_emigration_pressure)))

    (effects
      (emigrate-oldest ?count)
      (log _emigration_wave)))
)

(hsim-event homeostat_immigration
  (nl         "homeostat: immigration wave (alive=?alive)")
  (schedule   (annually january))
  (rng-stream homeostat)

  (let ((?alive    (alive-count))
        (?target   (homeostat_target_population))
        (?pressure (/ ?alive ?target))
        (?count    (homeostat_immigration_count)))

    (when (< ?pressure (homeostat_immigration_pressure)))

    (effects
      (spawn-immigrant ?count)
      (log _immigration_wave)))
)
