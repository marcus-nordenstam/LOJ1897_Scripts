; ----------------------------------------------------------------------------
; pursue-kill - an intent to kill ({@self intent {@self kill ?victim}}, minted by the homicide
; intenders under thinks/cooldown/) is carried out by the first means @self has: a strong
; hand strangles, a man holding a firearm shoots, a man with the fee in his pocket hires it
; done. With none he resolves to get a gun - a sub-intent, worth what the killing is worth.
; The killing act concluding ends the intent; the victim dying ends its intenders.
; ----------------------------------------------------------------------------

(define-macro strangling_strength () 0.45)
(define-macro assassin_fee_coins () 80)

(driver {@self intent {@self kill ?victim}}:?intent
  (preemptive-or
    (try
      (role @self {@self strength ?strength}
        (when (>= ?strength (strangling_strength)))
        (effects (maintain-proposal {@self strangle ?victim}))))
    (try
      (when (not (empty (spatial @self hold [k firearm]))))
      (effects (maintain-proposal {@self shoot ?victim})))
    (try
      (when (>= (carrying-cash-count @self) (assassin_fee_coins)))
      (effects (maintain-proposal {@self hire-assassin ?victim})))
    (try
      (when (empty (spatial @self hold [k firearm])))
      (effects (maintain-intent {@self intent {@self acquire [k firearm]}})))))
