; ----------------------------------------------------------------------------
; Conduct bands (per-observer repute layer, OTHER side). Bands a tracked person's
; conduct dimensions into {?other <dim> [k conduct_level ...]} beliefs in @self's OWN
; pool (via mint-band-about - never entering ?other's mind), abduced from the character
; impressions @self has formed by witnessing ?other's acts (abduction v2). Only NEGATIVE
; evidence exists (the dark-tetrad impressions), so a dim @self has heard ill of drops to
; `lax`; a dim it has no evidence for is simply not minted and reads `fair` in the fold
; (unknown -> benefit of the doubt). So an observer thinks worse of someone only as it
; witnesses bad character - reputation is evidence-grounded and non-uniform.
;
; Mapping: callous / selfish (psychopathy / narcissism) -> lax honesty + generosity;
; hot_tempered (volatility) -> lax sobriety. diligence has no abduced impression, so it
; is never banded down for others (always reads fair). The self side (conduct_bands.hs)
; bands @self's OWN four dims from their real values. The (or ... held-lax) role input
; keeps the event eligible so a band can toggle back OFF if the impression is forgotten.
; ----------------------------------------------------------------------------

(npc-think classify_others_conduct
  ; Per-observer: re-bands a tracked ?other from the impressions @self holds of them (seem /
  ; the held-lax bands). The mint-band hysteresis makes a same-band value a no-op.
  (rng-stream behaviour)

  (role ?other (or {?other seem ?}
                   {?other honesty    [k conduct_level lax]}
                   {?other generosity [k conduct_level lax]}
                   {?other sobriety   [k conduct_level lax]}))

  (effects
    (mint-band-about {?other honesty}
      (clamp (+ (prob {?other seem [k impression callous]})
                (prob {?other seem [k impression selfish]})) 0 1)
      [k conduct_level lax] 0.5)
    (mint-band-about {?other generosity}
      (clamp (+ (prob {?other seem [k impression callous]})
                (prob {?other seem [k impression selfish]})) 0 1)
      [k conduct_level lax] 0.5)
    (mint-band-about {?other sobriety}
      (prob {?other seem [k impression hot_tempered]})
      [k conduct_level lax] 0.5)))
