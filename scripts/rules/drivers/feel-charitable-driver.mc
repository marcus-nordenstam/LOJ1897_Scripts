; ----------------------------------------------------------------------------
; feel-charitable - almsgiving is a virtue: a days-since-last-alms ramp x compassion, capped
; low, so it stays a rare leisure act and the uncompassionate never give. He gives at the
; church he knows nearest (tasks/give-charity-task.mc). The 20-day cooldown is the floor.
; ----------------------------------------------------------------------------


(driver feel-charitable
  (cooldown 20 d try-until-succ)
  (role @self {@self compassion ?compassion}
              {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
    (role ?venue [k church-building] (select (score (near @self ?venue)) (policy roulette unknown-last))
      (when (>= (days-since-last {@self GIVE-ALMS /succ /ever}) 20))
      (declare-utility want (* 10.0 (* ?compassion
                  (min (* (days-since-last-float {@self GIVE-ALMS /succ /ever}) 0.8) 25.0))))
      (effects (maintain-proposal {@self give-charity ?venue})))))
