; ----------------------------------------------------------------------------
; putter driver. The putter TASK itself (wander / cache / done) lives in
; npc-tasks/putter-task.mc; want_putter is the lane that RAISES it: while at home, maintain
; a putter round - it only makes sense to putter at home.
; ----------------------------------------------------------------------------


(npc-think want_putter
  (lock)
  (cooldown 1 m try-until-succ)
  (role ?home {@self home ?home}
    (role @self (spatial @self building ?home)
      (utility idle)
      (effects (maintain-proposal {@self putter ?home})))))
