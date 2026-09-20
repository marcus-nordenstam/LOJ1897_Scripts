; ----------------------------------------------------------------------------
; read-mail drivers. The read-mail TASK itself (locate / go / take / read / done) lives in
; npc-tasks/read-mail-task.hs; these are the lanes that RAISE it.
;
; want_read_mail - the daily home post: at home, sweep the home mail once a day. A cooldown
;   driver: the bout ends when the read-mail it maintains concludes, and the expiry re-arms it
;   a day later - a bare days-since-last gate is false for too short a window to be seen by
;   an NPC who deliberates every other day. Errand band: it rides the ordinary errand
;   competition. The recruit officer's workplace read-mail rides the recruit-staff duty.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

(npc-think want_read_mail
  (cooldown 1 d)
  (role ?home {@self home ?home})
  (role @self (spatial @self building ?home))
  (when (>= (days-since-last {@self read-mail ?home /succ}) 1))
  (utility errand)
  (effects (maintain-proposal {@self read-mail ?home})))

