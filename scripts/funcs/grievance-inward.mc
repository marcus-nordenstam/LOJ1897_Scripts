; (despairing ?who) - ?who is past the despair + withdrawal gate a suicide is decided on:
; stress unrelieved by contentment, and withdrawn from others.
(define-func despairing (?who)
  (any {?who stress ?stress=0.0})
  (any {?who contentment ?contentment=0.5})
  (any {?who withdrawal ?withdrawal=0.0})
  (and (>= (* ?stress (- 1.0 ?contentment)) (suicide_despair_min))
       (>= ?withdrawal (suicide_withdrawal_min))))
