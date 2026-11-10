; ----------------------------------------------------------------------------
; Marriage, pursued. An intent to wed ({@self intent {@self wed ?partner}}) comes from the groom's
; matching intenders (intenders/betrothal-intender.mc, advantageous-match-intender.mc,
; love-match-intender.mc), from honouring a betrothal on both sides (intenders/wed-intender.mc)
; and from a founding match. The man proposes; the woman plans the wedding at her home and
; invites him to it; on its day each weds at it (tasks/wed-task.mc). Marrying ends the intent
; with its intenders.
; ----------------------------------------------------------------------------

(include "../../macros/occasion-macros.mc")

(driver {@self intent {@self wed ?partner}}:?intent
  (preemptive-or
    (try
      (belief {@self gender [k male]}
                  -{@self fiancee ?partner}
        (effects (maintain-proposal {@self propose-marriage ?partner}))))
    (try
      (role ?occ {@self organize [k wedding]:?occ}
                 -{@self invite ?partner ?occ}
        (effects (maintain-proposal {@self invite-guest ?partner ?occ} /quit-trying-on-fail))))
    (try
      (role ?occ {@self organize [k wedding]:?occ} {?occ held-on ?held-on}
        (when (date-is-today ?held-on))
        (effects (maintain-proposal {@self wed ?partner}))))
    (try
      (role ?occ [k wedding] {?partner invite @self ?occ} {?occ held-on ?held-on}
        (when (date-is-today ?held-on))
        (effects (maintain-proposal {@self wed ?partner}))))
    (try
      (belief {@self gender [k female]}
                  {@self fiancee ?partner}
                  (none {@self organize [k wedding]})
        (effects (maintain-proposal {@self plan-gathering [k wedding] (wedding-date)}))))))
