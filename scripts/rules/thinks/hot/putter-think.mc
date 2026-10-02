; ----------------------------------------------------------------------------
; putter driver. The putter TASK itself (wander / cache / done) lives in
; tasks/putter-task.mc; want-putter is the driver that RAISES it: while at home, maintain
; a putter round - it only makes sense to putter at home.
; ----------------------------------------------------------------------------


(think want-putter
  (lock)
  (cooldown 1 m try-until-succ)
  (role ?home {@self home ?home}
    (role @self (spatial @self unit ?home)
      (declare-utility idle)
      (effects (maintain-proposal {@self putter ?home})))))
