; ----------------------------------------------------------------------------
; read_mail drivers. The read_mail TASK itself (locate / go / take / read / done) lives in
; npc-tasks/read_mail-task.hs; these are the lanes that RAISE it.
;
; want_read_mail - the daily home post: at home, sweep the home mail on a 24h refractory.
;   Errand band: it rides the ordinary errand competition. The recruit officer's workplace
;   read_mail rides the recruit_staff duty independently.
; rm_sat_probe - a saturation debug probe (no task gate).
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think want_read_mail
  (role ?home {@self home ?home})
  (when (and (in-building @self ?home)
             (>= (days-since-last {@self read_mail ?home /succ}) 1)))
  (utility errand)
  (effects (debug-print "WANT_RM") (maintain-proposal {@self read_mail ?home})))

(npc-think rm_sat_probe
  (role ?home {@self home ?home})
  (when (and (in-building @self ?home) (>= (now-hour) 6) (<= (now-hour) 11)))
  (effects
    (tolerate (now-abs-seconds): ?n)
    (tolerate (abs-seconds (highest /end {@self read_mail ?home /succ}).end): ?e)
    (debug-print "RM_SAT n=?n e=?e")))
