; ----------------------------------------------------------------------------
; read-mail drivers. The read-mail TASK itself (locate / go / take / read / done) lives in
; npc-tasks/read-mail-task.hs; these are the lanes that RAISE it.
;
; want_read_mail - the daily home post: at home, sweep the home mail on a 24h refractory.
;   Errand band: it rides the ordinary errand competition. The recruit officer's workplace
;   read-mail rides the recruit-staff duty independently.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

(npc-think want_read_mail
  (role ?home {@self home ?home})
  (when (and (spatial @self building ?home)
             (>= (days-since-last {@self read-mail ?home /succ}) 1)))
  (utility errand)
  (effects (maintain-proposal {@self read-mail ?home})))

