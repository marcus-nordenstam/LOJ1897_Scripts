; ----------------------------------------------------------------------------
; want-drink - the non-dependent's drink pressure; it raises go-drink
; (tasks/go-drink-task.mc). A dependent's pressure is relapse (relapse-think.mc),
; which raises the same task.
; ----------------------------------------------------------------------------

(think want-drink
  (cooldown 3 d try-once)
  (role @self {@self industriousness ?industriousness}
              {@self withdrawal ?withdrawal}
              {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
              -{@self craving [k alcohol]}
    (when    (>= (days-since-last {@self DRINK /succ /ever}) 3))
    (utility want (* 10.0 (* (min (+ 0.35
                                    (* 0.9 (- 1.0 ?industriousness))
                                    (* 0.8 ?withdrawal)) 1.5)
                             (min (* (days-since-last-float {@self DRINK /succ /ever}) 2.0) 30.0))))
    (effects (maintain-proposal {@self go-drink}))))
