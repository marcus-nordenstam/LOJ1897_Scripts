; ----------------------------------------------------------------------------
; coercion_macros.hs - the blackmail press sequence (coercion.hs).
;
; (press-coercion ?victim): one month's turn of the repeat-demand screw. If
; the leverage is spent - AS THE BLACKMAILER KNOWS IT: he believes the
; victim's public chastity name is already stained (the reputed_chastity band
; travels the believe_about mirror / gossip, so a public disgrace reaches
; him) - the anchor ends: a secret everyone knows coerces nobody. Otherwise
; the demand is pressed - the victim's threatened
; SAY record + exposure_risk pressure refresh (compounding salience walks
; her from bribe / confess toward the kill tail across ticks, unscripted) -
; and half the months a blackmail note rides the covert letter channel: the
; anonymous {@self coerce ?victim {?victim lover @self}} demand note, a
; DEDICATED kind so a campaign cannot exhaust the conspiracy-letter cache cap
; and a detective can tell the papers apart.
; ----------------------------------------------------------------------------

(define-macro press-coercion (?victim)
  (if (or (believes {?victim reputed_chastity [k chastity_repute tarnished]})
          (believes {?victim reputed_chastity [k chastity_repute disgraced]}))
      (end-belief @self extort ?victim)
      (do
        (deliver-coercion-threat ?victim)
        (if (chance 0.5)
            (send-covert-letter ?victim
                                 (written-msg {@self coerce ?victim {?victim lover @self}})
                                 [k blackmail_note])))))
