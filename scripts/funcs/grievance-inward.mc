; A confidant to witness ?who's ideation - their living spouse, else the first friend
; they know (read from ?who's OWN relations). The rare servant-only confidant is not
; modelled; the truly alone die unwitnessed.
(define-func pick-confidant (?who)
  (any {?who spouse ?spouse=@nothing})
  (any {?who friend ?friend=@nothing})
  (if (and (substantial ?spouse) (alive ?spouse))
      (then ?spouse)
      (else ?friend)))

(define-func resolve-suicide (?who)
  (any {?who stress ?stress=0.0})
  (any {?who contentment ?contentment=0.5})
  (any {?who withdrawal ?withdrawal=0.0})
  (bind (pick-confidant ?who) ?conf)
  (if (substantial ?conf)
      (then (begin-belief ?conf {@self mention [k suicide]})))
  (if (and (>= (* ?stress (- 1.0 ?contentment)) (suicide_despair_min))
           (>= ?withdrawal (suicide_withdrawal_min)))
      (then (begin-goal {@self DIE [k suicide]}))))
