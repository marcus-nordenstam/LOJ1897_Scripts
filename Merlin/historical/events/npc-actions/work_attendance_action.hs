; ----------------------------------------------------------------------------
; work_attendance (npc-action lane) - the shift-stay act of the daily WORK-
; ATTENDANCE lane. The thinks that promote into it live in
; npc-think/work_attendance.hs.
;
; The shift stay, promoted from the work desire at the workplace. The stay's
; END HOUR (?until) arrives ON the action pattern - day_work reads the shift
; off the job beliefs and picks the next boundary (lunch or shift end) THINK-
; side; the action only turns the given hour into a duration off the world
; clock. On completion the actor re-deliberates (lunch / resume / home).
; ----------------------------------------------------------------------------

(npc-action {@self work ?wp ?until}
  (duration (minutes-until-hour ?until))
  (effects (set-outcome {@self work ?wp ?until} succ)))
