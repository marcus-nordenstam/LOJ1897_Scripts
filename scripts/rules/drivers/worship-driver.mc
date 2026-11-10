; ----------------------------------------------------------------------------
; worship - the churchgoing drives. Each raises the attend-church-service task
; (tasks/attend-church-service-task.mc), which gets him into a nave and proposes WORSHIP
; there.
;
;   want-worship:      a lonely man's want of company at a service, swung by politeness.
;   sunday-observance: the devout's observance. Devoutness makes worship a standing duty to
;                      his parish (worship-duty); each Sunday turns it into the day's
;                      obligation (sabbath), which this driver reads at the obligation band and
;                      attending discharges (reflexes/obligation-worship.mc).
; A third drive, rehabilitation (rehabilitation-driver.mc), raises the same task on a
; disreputable man's 15-day itch; the sources sum on the one proposal.
; ----------------------------------------------------------------------------

(include "../../macros/intensity-macros.mc")

(driver want-worship-driver
  (cooldown 3 d try-until-succ)
  (belief {@self company [k lonely|isolated]}
              {@self politeness ?politeness}
              {@self enthusiasm ?enthusiasm}
              {@self withdrawal ?withdrawal}
              {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
    (role ?church [k church-org] {@self member-of ?church}
      (when (service-due ?church))
      (declare-utility want (* (company-value ?enthusiasm ?withdrawal)
                               (clamp (+ 1.0 (delib-ctr ?politeness (k-drive-trait-swing))) 0.0 2.0)))
      (effects (maintain-proposal {@self attend-church-service})))))


(driver sunday-observance-driver
  (role ?church {@self obligation {@self attend-church-service} ?church}
    (when (service-due ?church))
    (declare-utility obligation)
    (effects (maintain-proposal {@self attend-church-service}))))
