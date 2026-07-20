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
; keeps the event on-agenda to toggle a band back OFF if the impression is forgotten.
; ----------------------------------------------------------------------------

(npc-think classify_others_conduct
  ; Reactive per-observer: re-band a tracked ?other the instant an impression of them commits or
  ; is forgotten. Triggers are DERIVED from the role's own belief filters (seems / the held-lax
  ; bands) - the subject-agnostic seam re-schedules on the {?other seems ?} write in @self's pool.
  ; The event mints {?other honesty/generosity/sobriety} which are its OWN trigger labels; that
  ; self-write hits the do_reschedule k_firing bail + the mint-band hysteresis, so it never loops.
  (schedule on-changed)
  (if-blocked hold)
  (rng-stream behaviour)

  (role ?other (or (believes {?other seems ?})
                   (believes {?other honesty    [k conduct_level lax]})
                   (believes {?other generosity [k conduct_level lax]})
                   (believes {?other sobriety   [k conduct_level lax]})))

  (effects
    (mint-band-about {?other honesty}
      (clamp (+ (believes {?other seems [k impression callous]})
                (believes {?other seems [k impression selfish]})) 0 1)
      [k conduct_level lax] 0.5)
    (mint-band-about {?other generosity}
      (clamp (+ (believes {?other seems [k impression callous]})
                (believes {?other seems [k impression selfish]})) 0 1)
      [k conduct_level lax] 0.5)
    (mint-band-about {?other sobriety}
      (believes {?other seems [k impression hot_tempered]})
      [k conduct_level lax] 0.5)))
