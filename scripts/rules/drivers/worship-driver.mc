; ----------------------------------------------------------------------------
; worship - the churchgoing drives. Each raises the attend-church-service task
; (tasks/attend-church-service-task.mc), which gets him into a nave and proposes WORSHIP
; there; the drives read the {@self WORSHIP} act belief for days-since-last, so a service
; relieves them all at once.
;
;   want-worship:      a churchgoer (some politeness) overdue for a service. The pressure
;                      ramps with days since the last one, swung by politeness.
;   sunday-observance: the devout's observance. Devoutness makes worship a standing duty to
;                      his parish (worship-duty); each Sunday turns it into the day's
;                      obligation (sabbath), which this driver reads at the obligation band and
;                      attending discharges (reflexes/obligation-worship.mc).
; A third drive, rehabilitation (rehabilitation-driver.mc), raises the same task on a
; disreputable man's 15-day itch; the sources sum on the one proposal.
; ----------------------------------------------------------------------------

(include "../../macros/intensity-macros.mc")

(driver want-worship
  (cooldown 3 d try-until-succ)
  (role @self {@self politeness ?politeness}
              {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
    (role ?church [k church-org] {@self member-of ?church}
      (when    (and (>= (days-since-last {@self WORSHIP /succ /ever}) 3)
                    (>= ?politeness 0.3)
                    (service-due ?church)))
      (declare-utility want (* (* 500.0 (clamp (/ (- (days-since-last-float {@self WORSHIP /succ /ever}) 3.0)
                                           (- 21.0 3.0))
                                        0.0 1.0)) (clamp (+ 1.0 (delib-ctr ?politeness (k-drive-trait-swing))) 0.0 2.0)))
      (effects (maintain-proposal {@self attend-church-service})))))


(driver sunday-observance
  (role ?church {@self obligation {@self attend-church-service} ?church}
    (when (service-due ?church))
    (declare-utility obligation)
    (effects (maintain-proposal {@self attend-church-service}))))
