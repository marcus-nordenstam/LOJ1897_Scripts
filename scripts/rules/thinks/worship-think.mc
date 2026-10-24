; ----------------------------------------------------------------------------
;   sunday-observance: the devout's observance. Devoutness makes worship a standing duty to
;                      his parish (worship-duty); each Sunday turns it into the day's
;                      obligation (sabbath), which this driver reads at the obligation band and
;                      attending discharges (reflexes/obligation-worship.mc).
; ----------------------------------------------------------------------------

; A devout man's standing duty to his parish, the church org he is a member of, held while he
; is devout.
(think worship-duty
  (role @self {@self devoutness [k devout]}
              {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
    (role ?church [k church-org] {@self member-of ?church}
      (effects (maintain-belief {@self duty-to ?church attend-church-service})))))

; Sunday turns the duty into the day's obligation to attend the service, once: an obligation
; discharged today is the day's.
(think service-hours-known
  (role ?church [k church-org] {@self member-of ?church}
    (effects (learn-service-hours ?church))))
(think sabbath
  (role ?church {@self duty-to ?church attend-church-service}:?duty
    (when (and (= (time weekday) (sunday_weekday))
               (none {@self obligation {@self attend-church-service} ?church})
               (>= (days-since-last {@self obligation {@self attend-church-service} ?church /past}) 1)))
    (effects
      (begin-belief {@self obligation {@self attend-church-service} ?church /caused_by ?duty})
      (book-service-alarms ?church))))

; A Sunday gone by unattended: the obligation lapses and strains him, the strain caused by the
; duty he still holds.
(think sabbath-lapsed
  (role ?church {@self duty-to ?church attend-church-service}:?duty
                {@self obligation {@self attend-church-service} ?church}:?obligation
    (when (!= (time weekday) (sunday_weekday)))
    (effects
      (mint-pressure-caused [k obligation-strain] @nothing 168.0 ?duty)
      (end-belief ?obligation))))
