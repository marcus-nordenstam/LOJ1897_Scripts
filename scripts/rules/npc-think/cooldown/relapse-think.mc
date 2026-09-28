; ----------------------------------------------------------------------------
; relapse - a DEPENDENT drinker's drink pressure (the standing {@self craving alcohol}).
; A craving never decays, so he relapses often: a shorter fuse and a higher band than
; want_drink, which excludes him. It raises the same go-drink task.
; ----------------------------------------------------------------------------

(npc-think relapse
  (cooldown 1 d try-once)
  (role @self {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
              {@self craving [k alcohol]}
    (when (>= (days-since-last {@self DRINK /succ /ever}) 1))
    ; Withdrawal is a drive, not a trait, so escalating the band on it is legitimate.
    (utility (if (>= (target-or @self withdrawal 0.0) 0.7) (then crisis) (else need))
             (* 10.0 (* (min (* (+ 0.5 (* 0.8 (target-or @self withdrawal 0.0)))
                                (+ 0.6 (* 0.6 (- 1.0 (target-or @self industriousness 0.0))))
                                (- 1.3 (* 0.6 (piety)))
                                (- 1.3 (* 0.6 (belonging)))) 1.6)
                        (min (* (days-since-last-float {@self DRINK /succ /ever}) 5.0) 45.0))))
    (effects (maintain-proposal {@self go-drink}))))
