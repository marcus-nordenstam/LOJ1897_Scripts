; ----------------------------------------------------------------------------
; betrayal-kill.mc - the LETHAL answer to a betrayal. A DRIVER, not an appraisal:
; The betray-act reflex rows mint the reaction (anger @ the unfaithful partner, contempt @
; the interloper); this rule READS those emotions and resolves on the kill,
; /caused_by-pinned to the emotion it reads. It mints nothing - so the murderous
; drive fades as the anger / contempt cools.
;
; The blame decision reads the layered score macros (score_macros.mc) over the minted
; emotions: kill BOTH when (dual-outrage-score) >= 2.5 (rare); else the partner when
; (blame-partner-score) >= (blame-interloper-score); else the interloper. The rage tip
; (dark-propensity over rage-disposition) fires ONCE and the latch holds it,
; keeping this the lethal tail (siblings: crime-of-passion / clear_marriage /
; rid-of-spouse; non-lethal fallout: affair-fallout).
; ----------------------------------------------------------------------------


(intender betrayal-kill
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
      {@self spouse|lover ?partner}
      {@self emotion [k anger] ?partner}:?anger_bond
      (select (policy first-match))
      (role ?interloper {?interloper isa [k human], condition [k alive]}
        {?partner lover ?interloper}
        -{?partner spouse ?interloper}
        (select (policy first-match))

        ; The REASON: the appraised emotions (minted by the betray-act reflex rows). Read as the
        ; /caused_by anchors, never re-minted.
        (bind (any {@self emotion [k contempt] ?interloper}) ?contempt_bond)

        ; Fires only once the betrayal is appraised (anger present); the rage tip fires ONCE
        ; (0.02 base * dark-propensity), then the latch holds it.
        (when (latch-eval (chance (* (crime-scale) 0.02
                                  (* (- 1.0 ?inhibition) (* 0.5 (+ ?volatility ?psychopathy)))))))
        (declare-utility want)
        ; Dual (kill BOTH) when the outrage clears the bar; else the more-blamed corner.
        (preemptive-or
          (try
            (when (>= (+ (emotion-load [k anger]) (+ ?decorum ?machiavellianism)) 2.5))
            (effects
              (maintain-intent {@self intent {@self kill ?partner}} /caused_by ?anger_bond)
              (maintain-intent {@self intent {@self kill ?interloper}} /caused_by ?contempt_bond)))
          (try
            (when (>= (+ ?narcissism (+ (- 1.0 ?compassion) (+ ?decorum (flip (< (stance-band ?partner warmth) 0.0)
                                                                            1.0
                                                                            0.0))))
                      (+ (+ (max 0.0 (stance-band ?partner warmth)) (* 0.5 (stance-band ?partner attraction)))
                         (+ ?compassion
                            (flip (< (stance-band ?interloper warmth) 0.0)
                                  (- 0.0 (stance-band ?interloper warmth))
                                  0.0)))))
            (effects (maintain-intent {@self intent {@self kill ?partner}} /caused_by ?anger_bond)))
          (try
            (effects (maintain-intent {@self intent {@self kill ?interloper}} /caused_by ?contempt_bond))))))))
