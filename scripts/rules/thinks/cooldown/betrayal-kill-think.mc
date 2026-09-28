; ----------------------------------------------------------------------------
; betrayal-kill.mc - the LETHAL answer to a betrayal. A DRIVER, not an appraisal:
; The betray-act reflex rows mint the reaction (anger @ the unfaithful partner, contempt @
; the interloper); this rule READS those emotions and maintain-proposes the kill,
; /caused_by-pinned to the emotion it reads. It mints nothing - so the murderous
; drive fades as the anger / contempt cools.
;
; The blame decision reads the layered score macros (score_macros.mc) over the minted
; emotions: kill BOTH when (dual-outrage-score) >= 2.5 (rare); else the partner when
; (blame-partner-score) >= (blame-interloper-score); else the interloper. The rage tip
; (dark-propensity over rage-disposition) fires ONCE then the running proposal latches,
; keeping this the lethal tail (siblings: crime-of-passion / clear_marriage /
; rid-of-spouse; non-lethal fallout: affair-fallout).
; ----------------------------------------------------------------------------


(think betrayal-kill
  (cooldown 1 m try-once)
  (rng-stream perpetration)

  (role @self {@self compassion ?compassion}
              {@self decorum ?decorum}
              {@self volatility ?volatility}
              {@self psychopathy ?psychopathy}
              {@self machiavellianism ?machiavellianism}
              {@self narcissism ?narcissism}
              {@self inhibition ?inhibition} 
    ; The unfaithful partner + the interloper the actor believes she keeps (a JOIN over
    ; @self's OWN beliefs; any_human keeps both to the believed-alive, so a dead corner
    ; drops the drive).
    (role ?partner {?partner isa [k human], condition [k alive]}
      {@self spouse|lover ?partner} (select (policy first-match))
      (role ?interloper {?interloper isa [k human], condition [k alive]}
        {?partner lover ?interloper}
        -{?partner spouse ?interloper}
        (select (policy first-match))

        ; The REASON: the appraised emotions (minted by the betray-act reflex rows). Read as the
        ; /caused_by anchors, never re-minted.
        (bind (any {@self emotion [k anger] ?partner}) ?anger_bond)
        (bind (any {@self emotion [k contempt] ?interloper}) ?contempt_bond)

        ; Fires only once the betrayal is appraised (anger present); the rage tip fires ONCE
        ; (0.02 base * dark-propensity), then a running kill proposal latches it.
        (when (and (substantial ?anger_bond)
                   (or {@self kill ?partner}
                       {@self kill ?interloper}
                       (chance (* (crime-scale) 0.02
                                  (* (- 1.0 ?inhibition) (* 0.5 (+ ?volatility ?psychopathy))))))))
        (utility want)
        (effects
          ; Dual (kill BOTH) when the outrage clears the bar; else the more-blamed corner.
          (cond
            (case (>= (+ (emotion-load @self [k anger])
                         (+ ?decorum ?machiavellianism)) 2.5)
              (if -{?partner condition [k dead]}
                  (then (maintain-proposal {@self kill ?partner /caused_by ?anger_bond})))
              (if -{?interloper condition [k dead]}
                  (then (maintain-proposal {@self kill ?interloper /caused_by ?contempt_bond}))))
            (case (>= (+ ?narcissism (+ (- 1.0 ?compassion) (+ ?decorum (if (< (stance-band ?partner warmth) 0.0) (then 1.0) (else 0.0)))))
                      (+ (+ (max 0.0 (stance-band ?partner warmth)) (* 0.5 (stance-band ?partner attraction)))
                         (+ ?compassion
                            (if (< (stance-band ?interloper warmth) 0.0) (then (- 0.0 (stance-band ?interloper warmth))) (else 0.0)))))
              (if -{?partner condition [k dead]}
                  (then (maintain-proposal {@self kill ?partner /caused_by ?anger_bond}))))
            (else
              (if -{?interloper condition [k dead]}
                  (then (maintain-proposal {@self kill ?interloper /caused_by ?contempt_bond}))))))))))
