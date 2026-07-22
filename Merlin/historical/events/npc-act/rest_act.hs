; ----------------------------------------------------------------------------
; rest (npc-action) - the sleep act of the FATIGUE / REST lane. The intra-day
; think rules (seek_rest / sleep / idle_go_home) live in npc-think/rest.hs;
; this file holds the durative sleep act promoted from the SLEEP desire.
; ----------------------------------------------------------------------------

; The sleep act, promoted from the SLEEP desire at home. Duration = until the morning
; alarm, capped by any pending obligation (attend / supper); minutes-until-attend /
; -until-hour are huge sentinels when nothing is pending. The engine resets fatigue on
; completion (keyed on the SLEEP label); the body just ends the act-belief.
(npc-action sleep_act
  (act {@self SLEEP})
  ; re-derive the home off @self's own belief for the supper-hour duration cap (a pure
  ; value-op bind, not a gate - the SLEEP desire only promotes at home).
  (bind (target {@self home}) ?home)
  (duration (min (minutes-until-alarm @self)
                 (minutes-until-attend @self)
                 (minutes-until-hour (target {?home supper_hour}))))
  (act-effects (end-act {@self SLEEP})))
