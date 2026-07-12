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
  (when (and (believes {@self work ?wp})
             (bind {@self job ?job})
             (bind {?job (work-hours-today-label) ?start ?end})))
  (duration (min (minutes-until-shift-end ?end) (minutes-until-hour 12)))
  (act-effects (end-act {@self work ?wp})))
