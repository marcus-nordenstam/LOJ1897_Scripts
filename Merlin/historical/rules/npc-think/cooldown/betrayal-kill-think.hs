; ----------------------------------------------------------------------------
; betrayal_kill.hs - the LETHAL answer to a betrayal. A DRIVER, not an appraisal:
; The betray_act reflex rows mint the reaction (anger @ the unfaithful partner, contempt @
; the interloper); this rule READS those emotions and maintain-proposes the kill,
; /caused_by-pinned to the emotion it reads. It mints nothing - so the murderous
; drive fades as the anger / contempt cools.
;
; The blame decision reads the layered score macros (score_macros.hs) over the minted
; emotions: kill BOTH when (dual-outrage-score) >= 2.5 (rare); else the partner when
; (blame-partner-score) >= (blame-interloper-score); else the interloper. The rage tip
; (dark-propensity over rage-disposition) fires ONCE then the running proposal latches,
; keeping this the lethal tail (siblings: crime_of_passion / clear_marriage /
; rid_of_spouse; non-lethal fallout: affair_fallout).
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think betrayal_kill
  (cooldown 1 m)
  (rng-stream perpetration)

  (role @self )
  ; The unfaithful partner + the interloper the actor believes she keeps (a JOIN over
  ; @self's OWN beliefs; any_human keeps both to the believed-alive, so a dead corner
  ; drops the drive).
  (role ?partner (any_human ?partner)
    {@self spouse|lover ?partner} (select (policy first-match)))
  (role ?interloper (any_human ?interloper)
    {?partner lover ?interloper}
    (none {?partner spouse ?interloper})
    (select (policy first-match)))

  ; The REASON: the appraised emotions (minted by the betray_act reflex rows). Read as the
  ; /caused_by anchors, never re-minted.
  (any {@self emotion [k anger] ?partner}):?anger_bond
  (any {@self emotion [k contempt] ?interloper}):?contempt_bond

  ; Fires only once the betrayal is appraised (anger present); the rage tip fires ONCE
  ; (0.02 base * dark-propensity), then a running kill proposal latches it.
  (when (and (substantial ?anger_bond)
             (or (has-proposal {@self kill ?partner})
                 (has-proposal {@self kill ?interloper})
                 (chance (* (crime-scale) 0.02
                            (dark-propensity (rage-disposition @self)))))))
  (utility want)
  (effects
    ; Dual (kill BOTH) when the outrage clears the bar; else the more-blamed corner.
    (if (>= (dual-outrage-score) 2.5)
        (then (if (none {?partner condition [k dead]})
                  (then (maintain-proposal {@self kill ?partner /caused_by ?anger_bond})))
              (if (none {?interloper condition [k dead]})
                  (then (maintain-proposal {@self kill ?interloper /caused_by ?contempt_bond}))))
        (else (if (>= (blame-partner-score ?partner)
                      (blame-interloper-score ?partner ?interloper))
                  (then (if (none {?partner condition [k dead]})
                            (then (maintain-proposal {@self kill ?partner /caused_by ?anger_bond}))))
                  (else (if (none {?interloper condition [k dead]})
                            (then (maintain-proposal {@self kill ?interloper /caused_by ?contempt_bond})))))))))
