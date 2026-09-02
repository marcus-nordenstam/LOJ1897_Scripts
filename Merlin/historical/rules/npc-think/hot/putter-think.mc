; ----------------------------------------------------------------------------
; putter driver. The putter TASK itself (wander / cache / done) lives in
; npc-tasks/putter-task.hs; want_putter is the lane that RAISES it: monthly, at home,
; begin a putter round.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

(npc-think want_putter
  (lock-rule)
  (cooldown 1 m)
  (role ?home {@self home ?home})
  (when (spatial @self building ?home))
  (utility idle)
  (effects (begin-proposal {@self putter ?home})))
