; ----------------------------------------------------------------------------
; Marriage, pursued. An intent to wed ({@self intent {@self wed ?partner}}) comes from the groom's
; matching intenders (intenders/betrothal-intender.mc, advantageous-match-intender.mc,
; love-match-intender.mc) and from fancying the one you are betrothed to (decide-wed-for-love).
; pursue-wed works it through: propose to the partner, then - the groom - plan the wedding and
; invite the bride, and on the day wed at it, whoever organized it. Marrying ends the intent
; with its intenders.
; ----------------------------------------------------------------------------

(include "../../macros/occasion-macros.mc")

(driver {@self intent {@self wed ?partner}}:?intent
  (preemptive-or
    (try
      (role @self -{@self fiancee ?partner}
        (effects (maintain-proposal {@self propose-marriage ?partner}))))
    (try
      (role ?occ {@self organize [k wedding]:?occ} {?occ held-on ?held-on}
        (when (date-in-current-month ?held-on))
        (effects (maintain-proposal {@self wed ?partner}))))
    (try
      (role ?occ [k wedding] {? invite @self ?occ} {?occ held-on ?held-on}
        (when (date-in-current-month ?held-on))
        (effects (maintain-proposal {@self wed ?partner}))))
    (try
      (role ?occ {@self organize [k wedding]:?occ}
                 -{@self invite ?partner ?occ}
        (effects (maintain-proposal {@self invite-guest ?partner ?occ}))))
    (try
      (role @self {@self gender [k male]}
                  (none {@self organize [k wedding]})
        (effects (maintain-proposal {@self plan-gathering [k wedding] (wedding-lead-months)}))))))
