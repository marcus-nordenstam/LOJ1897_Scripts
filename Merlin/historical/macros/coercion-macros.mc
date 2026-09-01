; ----------------------------------------------------------------------------
; coercion_macros.hs - the blackmail press sequence (coercion.hs).
;
; (press-coercion ?victim): one month's turn of the repeat-demand screw. If
; the leverage is spent - AS THE BLACKMAILER KNOWS IT: he already holds beliefs
; of the victim's OTHER liaisons (count (every {?victim lover ? /ever})), so her name
; is stained to him and a secret everyone knows coerces nobody - the anchor ends.
; Otherwise the demand is pressed - the victim's threatened
; SAY record + exposure-risk pressure refresh (compounding salience walks
; her from bribe / confess toward the kill tail across ticks, unscripted) -
; and half the months a blackmail note rides the covert letter channel: the
; anonymous {@self coerce ?victim {?victim lover @self}} demand note, a
; DEDICATED kind so a campaign cannot exhaust the conspiracy-letter cache cap
; and a detective can tell the papers apart.
; ----------------------------------------------------------------------------

(define-macro press-coercion (?victim)
  ; Leverage is spent once the blackmailer already knows of the victim's OTHER
  ; liaisons (per-observer chastity: (count (every {?victim lover ? /ever})) counts the
  ; victim's affairs THIS mind holds - excluding its own dyad, which is {@self lover
  ; ?victim}, a different subject). If she is already known-unchaste to him, threatening
  ; to expose their affair no longer bites.
  (if (>= (count (every {?victim lover ? /ever})) 1)
      (then (end-belief {@self extort ?victim}))
      (else
        ; Refresh the standing extort anchor in the victim's mind (his renewed demand,
        ; perceived); the victim's coercion_pressure rule compounds the pressure off
        ; it. No act-record on a mere refresh - the anchor carries the demand.
        (begin-belief ?victim {@self extort ?victim})
        (if (chance 0.5)
            (then (send-covert-letter ?victim
                                 (nl-written-msg "I coerced ?victim into becoming my lover")
                                 [k blackmail-note]))))))

; (coercion-stake): the exposure-risk pressure delta a victim mints per month, as
; HE reckons it - the base window scaled by what publication would cost HIS OWN
; standing (class, self-known). begin-belief (salience ..) compounds it across months,
; walking him from bribe / confess toward the kill tail (deliberation_affinity).
(define-macro coercion-stake ()
  (* 1440
     (if (is-a (any {@self class-situation}).target [k class-situation upper]) (then 1.5)
       (else (if (is-a (any {@self class-situation}).target [k class-situation middle]) (then 1.2)
                (else 1.0))))))
