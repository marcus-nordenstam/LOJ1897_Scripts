; ----------------------------------------------------------------------------
; want_drink - the non-dependent's drink pressure; it raises go-drink
; (npc-tasks/go-drink-task.mc). A dependent's pressure is relapse (relapse-think.mc),
; which raises the same task.
; ----------------------------------------------------------------------------

(npc-think want_drink
  (cooldown 3 d try-once)
  (role @self {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
              -{@self craving [k alcohol]}
    (when    (>= (days-since-last {@self DRINK /succ /ever}) 3))
    (utility want (* 10.0 (* (min (+ 0.35
                                    (* 0.9 (- 1.0 (target-or @self industriousness 0.0)))
                                    (* 0.8 (target-or @self withdrawal 0.0))) 1.5)
                             (min (* (days-since-last-float {@self DRINK /succ /ever}) 2.0) 30.0))))
    (effects (maintain-proposal {@self go-drink}))))
