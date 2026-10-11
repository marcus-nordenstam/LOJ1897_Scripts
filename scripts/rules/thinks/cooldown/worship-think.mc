; ----------------------------------------------------------------------------
; worship - the churchgoing drives. Each raises the attend-church-service task
; (tasks/attend-church-service-task.mc), which gets him into a nave and proposes WORSHIP
; there; the drives read the {@self WORSHIP} act belief for days-since-last, so a service
; relieves them all at once.
;
;   want-worship:      a churchgoer (some politeness) overdue for a service. The pressure
;                      ramps with days since the last one, swung by politeness.
;   sunday-observance: the devout's observance. Devoutness makes worship a standing duty to
;                      his parish (worship-duty); a week without worship turns it into the
;                      week's obligation (sabbath), which this driver reads at the obligation band and
;                      attending discharges (reflexes/obligation-worship.mc).
; A third drive, rehabilitation (rehabilitation-think.mc), raises the same task on a
; disreputable man's 15-day itch; the sources sum on the one proposal.
; ----------------------------------------------------------------------------

(include "../../../macros/intensity-macros.mc")

(driver want-worship
  (cooldown 3 d try-until-succ)
  (role @self {@self politeness ?politeness}
              {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
    (when    (and (>= (days-since-last {@self WORSHIP /succ /ever}) 3)
                  (>= ?politeness 0.3)))
    (declare-utility want (* (* 500.0 (clamp (/ (- (days-since-last-float {@self WORSHIP /succ /ever}) 3.0)
                                         (- 21.0 3.0))
                                      0.0 1.0)) (clamp (+ 1.0 (delib-ctr ?politeness (k-drive-trait-swing))) 0.0 2.0)))
    (effects (maintain-proposal {@self attend-church-service}))))

; A devout man's standing duty to his parish, the church org he is a member of, held while he
; is devout.
(think worship-duty
  (role @self {@self devoutness [k devout]}
              {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
    (role ?church [k church-org] {@self member-of ?church}
      (effects (maintain-belief {@self duty-to ?church attend-church-service})))))

; A week gone by without worship turns the duty into the week's obligation to attend a service.
(think sabbath
  (role ?church {@self duty-to ?church attend-church-service}:?duty
    (when (and (>= (days-since-last {@self WORSHIP /succ /ever}) (days_per_week))
               (none {@self obligation {@self attend-church-service} ?church})))
    (effects (begin-belief {@self obligation {@self attend-church-service} ?church /caused_by ?duty}))))

(driver sunday-observance
  (role ?church {@self obligation {@self attend-church-service} ?church}
    (declare-utility obligation)
    (effects (maintain-proposal {@self attend-church-service}))))

; A week's obligation left unmet for a week lapses and strains him, the strain caused by the
; duty he still holds.
(think sabbath-lapsed
  (role ?church {@self duty-to ?church attend-church-service}:?duty
                {@self obligation {@self attend-church-service} ?church}:?obligation
    (when (>= (elapsed /days ?obligation) (days_per_week)))
    (effects
      (mint-pressure-caused [k obligation-strain] @nothing 168.0 ?duty)
      (end-belief ?obligation))))
