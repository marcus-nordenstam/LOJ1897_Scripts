; ----------------------------------------------------------------------------
; rest (npc-act) - the sleep act of the FATIGUE / REST lane. The intra-day
; think rules (seek_rest / sleep / idle_go_home) live in npc-think/rest.hs;
; this file holds the durative sleep act promoted from the SLEEP desire.
; ----------------------------------------------------------------------------

; The sleep act, promoted from the SLEEP desire at home. Duration = until the morning
; alarm, capped by any pending obligation (attend / supper); minutes-until-attend /
; -until-hour are huge sentinels when nothing is pending. The engine resets fatigue on
; completion (keyed on the SLEEP label); the body just ends the act-belief.
(npc-act sleep_act
  ; the home is a CACHED role (binds ?home for the duration read); the SLEEP
  ; act-desire stays live (act-lifecycle label - caching it would churn daily).
  (role ?home (believes {@self home ?home}))
  (when (believes {@self SLEEP}))
  (duration (min (minutes-until-alarm @self)
                 (minutes-until-attend @self)
                 (minutes-until-hour (target {?home supper_hour}))))
  (act-effects (end-act {@self SLEEP})))
