; ----------------------------------------------------------------------------
; coercion_macros.hs - the blackmail press sequence (coercion.hs).
;
; (press-coercion ?victim): one month's turn of the repeat-demand screw. If
; the leverage is spent - AS THE BLACKMAILER KNOWS IT: he already holds beliefs
; of the victim's OTHER liaisons (count-beliefs-about ?victim lover), so her name
; is stained to him and a secret everyone knows coerces nobody - the anchor ends.
; Otherwise the demand is pressed - the victim's threatened
; SAY record + exposure_risk pressure refresh (compounding salience walks
; her from bribe / confess toward the kill tail across ticks, unscripted) -
; and half the months a blackmail note rides the covert letter channel: the
; anonymous {@self coerce ?victim {?victim lover @self}} demand note, a
; DEDICATED kind so a campaign cannot exhaust the conspiracy-letter cache cap
; and a detective can tell the papers apart.
; ----------------------------------------------------------------------------

(define-macro press-coercion (?victim)
  ; Leverage is spent once the blackmailer already knows of the victim's OTHER
  ; liaisons (per-observer chastity: (count-beliefs-about ?victim lover) counts the
  ; victim's affairs THIS mind holds - excluding its own dyad, which is {@self lover
  ; ?victim}, a different subject). If she is already known-unchaste to him, threatening
  ; to expose their affair no longer bites.
  (if (>= (count-beliefs-about ?victim lover) 1)
      (then (end-belief @self extort ?victim))
      (else
        (deliver-coercion-threat ?victim)
        (if (chance 0.5)
            (then (send-covert-letter ?victim
                                 (written-msg {@self coerce ?victim {?victim lover @self}})
                                 [k blackmail_note]))))))
