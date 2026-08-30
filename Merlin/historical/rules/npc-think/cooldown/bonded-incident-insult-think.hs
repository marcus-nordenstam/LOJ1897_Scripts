; ----------------------------------------------------------------------------
; bonded_incident_insult (npc-think). The impulsive SPOKEN insult: @self lashes
; out at a co-present acquaintance, uttering a barb the victim (and any bystander)
; hears - blame and hurt-feelings ride the witnessed SAY, not a minted anchor.
; The actor's impulse is gated in (when): a dispositional base
; (low-politeness x narcissism) plus displaced anger (a high current ANGER load
; from ANY source), the victim stance-weighted so the disliked and despised are
; hit most (a 0.10 floor lets displaced anger land on any acquaintance).
;
; The (do ...) block runs per ?victim (after the role binds) and tolerantly
; captures the mockable material @self holds about the victim (each `-rel` var is
; the whole belief handle, or @fail with no abort) - only what @self knows or can
; see, so the insult is grounded. low_aspect-rel is the single worst of the four
; amiable traits; vol-rel the hot-head extreme. The barb_ladder cells read those
; handles by context: a high anger load -> the displaced-anger lash-out (perceptual
; barbs, what is at hand); otherwise the dispositional put-down (status barbs). A
; context with no material scores every row 0, the select binds nothing, and
; nothing is said (finding a barb is a condition). rank is the roulette weight.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(define-table barb_ladder
  (capture ?girth-rel ?height-rel ?sob-rel ?low_aspect-rel ?vol-rel ?low_class-rel ?pre-rel)
  (fields context          rank  barb_eval)

  ; displaced_anger: lashing out grabs what is visible at hand.
  (record displaced_anger  3    (if (matches ?girth-rel.target [k girth fat|thin]) (then ?girth-rel)
                                  (else (if (= ?height-rel.target [k height short]) (then ?height-rel)))))
  (record displaced_anger  2    (if (<= ?sob-rel.target 0.35) (then ?sob-rel)))
  (record displaced_anger  1    (if (<= ?low_aspect-rel.target 0.30) (then ?low_aspect-rel)
                                  (else (if (>= ?vol-rel.target 0.70) (then ?vol-rel)))))

  ; dispositional: the narcissist's put-down is status elevation.
  (record dispositional    4    ?low_class-rel)
  (record dispositional    3    (if (<= ?pre-rel.target 0.35) (then ?pre-rel)))
  (record dispositional    2    (if (<= ?low_aspect-rel.target 0.30) (then ?low_aspect-rel)
                                  (else (if (>= ?vol-rel.target 0.70) (then ?vol-rel)))))
  (record dispositional    1    (if (matches ?girth-rel.target [k girth fat|thin]) (then ?girth-rel)
                                  (else (if (= ?height-rel.target [k height short]) (then ?height-rel))))))

(npc-think bonded_incident_insult
  (cooldown 1 m)
  (rng-stream incidents)

  (role @self )
  (role ?victim (any_human ?victim)
                (personally-knows @self ?victim)
                (spatial ?victim co-located @self))

  ; Anger load is @self-only and (emotion-load) is not cheap - compute it ONCE and
  ; derive the ladder context from it, so neither the (when) nor the per-row
  ; select-row (when) re-evaluates it.
  (bind (emotion-load @self [k anger]) ?emo_load)
  (bind (if (> ?emo_load 0.5) (then displaced_anger) (else dispositional)) ?emo_ctx)

  ; The actor's impulse (dispositional base + displaced anger) and the victim-
  ; stance gate are both non-belief (chance) tests, so they live in (when).
  (when (and (chance (+ (* (crime-scale) 0.06
                           (- 1.0 (attr @self politeness))
                           (attr @self narcissism))
                        (* (crime-scale) 0.08 ?emo_load)))
             (chance (+ 0.10
                        (* 0.15 (+ (prob {@self dislike ?victim})
                                   (prob {@self disdain ?victim})))
                        (* 0.30 (+ (prob {@self detest  ?victim})
                                   (prob {@self despise ?victim})))))))

  ; The mockable material, read per victim - each tolerant, so a missing lane is
  ; just @fail (no abort). Each `-rel` var holds the whole belief.
  (do
    (tolerate (any {?victim girth ?}):?girth-rel)
    (tolerate (any {?victim height ?}):?height-rel)
    (tolerate (any {?victim sobriety ?}):?sob-rel)
    (tolerate (lowest /target {?victim politeness|industriousness|orderliness|compassion ?}):?low_aspect-rel)
    (tolerate (any {?victim volatility ?}):?vol-rel)
    (tolerate (any {?victim class_situation [k class_situation lower]}):?low_class-rel)
    (tolerate (any {?victim prestige ?}):?pre-rel))

  ; Compose the barb: context is the anger-driven ladder choice; ?barb-rel the
  ; belief @self voices. No material in that context -> nothing binds -> silence.
  (select-row (table barb_ladder)
    (bind context ?ctx)
    (bind rank ?rank)
    (bind barb_eval ?barb-rel)
    (when (= ?ctx ?emo_ctx))
    (score (if (is-belief ?barb-rel) (then ?rank) (else 0)))
    (policy roulette))

  (utility want)

  (effects
    (maintain-proposal {@self SAY (utterable-msg ?barb-rel (msg_class insult)) ?victim})))
