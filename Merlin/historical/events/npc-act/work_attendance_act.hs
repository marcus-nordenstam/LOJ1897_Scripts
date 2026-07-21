; ----------------------------------------------------------------------------
; work_attendance (npc-act lane) - the shift-stay act of the daily WORK-
; ATTENDANCE lane. The thinks that promote into it live in
; npc-think/work_attendance.hs.
;
; The shift stay, promoted from the work desire at the workplace. Re-binds the
; shift end off the job for the duration cap; ?wp (the workplace) is the act
; target. On completion the actor re-deliberates (-> lunch / home / rest). The
; stay yields at the lunch band via the (minutes-until-hour 12) cap -
; eligibility is only sampled at completions.
; ----------------------------------------------------------------------------

(npc-act work_act
  (act {@self work ?wp})
  ; re-derive the job + today's shift END off @self's own beliefs (pure value-ops, not
  ; gates): day_work only PROPOSES the stay while in-shift, so the shift belief - hence
  ; its aux end-hour - always resolves when this promotes.
  (bind (target {@self job}) ?job)
  (bind (auxiliary {?job (work-hours-today-label)}) ?end)
  (duration (min (minutes-until-shift-end ?end) (minutes-until-hour 12)))
  (act-effects (end-act {@self work ?wp})))
