; ----------------------------------------------------------------------------
; bonded-incident-insult (think). The impulsive SPOKEN insult: @self lashes
; out at a co-present acquaintance, uttering a barb the victim (and any bystander)
; hears - blame and hurt-feelings ride the witnessed SAY, not a minted anchor.
; The actor's impulse is gated in (when): a dispositional base
; (low-politeness x narcissism) plus displaced anger (a high current ANGER load
; from ANY source), the victim stance-weighted so the disliked and despised are
; hit most (a 0.10 floor lets displaced anger land on any acquaintance).
;
; The (do ...) block runs per ?victim (after the role binds) and tolerantly
; captures the mockable material @self holds about the victim (each capture holds
; the whole belief, or @fail with no abort) - only what @self knows or can
; see, so the insult is grounded. ?low_aspect is the single worst of the four
; amiable traits; ?volatility the hot-head extreme. The barb_ladder cells read those
; handles by context: a high anger load -> the displaced-anger lash-out (perceptual
; barbs, what is at hand); otherwise the dispositional put-down (status barbs). A
; context with no material scores every row 0, the select binds nothing, and
; nothing is said (finding a barb is a condition). rank is the roulette weight.
; ----------------------------------------------------------------------------


(define-table barb_ladder
  (capture ?girth ?height ?sobriety ?low_aspect ?volatility ?class-situation ?prestige)
  (fields context          rank  barb-eval)

  ; displaced_anger: lashing out grabs what is visible at hand.
  (record displaced_anger  3    (cond (case (matches ?girth.target [k fat|thin]) ?girth)
                                      (case (= ?height.target [k short])       ?height)))
  (record displaced_anger  2    (if (<= ?sobriety.target 0.35) (then ?sobriety)))
  (record displaced_anger  1    (cond (case (<= ?low_aspect.target 0.30) ?low_aspect)
                                      (case (>= ?volatility.target 0.70)        ?volatility)))

  ; dispositional: the narcissist's put-down is status elevation.
  (record dispositional    4    ?class-situation)
  (record dispositional    3    (if (<= ?prestige.target 0.35) (then ?prestige)))
  (record dispositional    2    (cond (case (<= ?low_aspect.target 0.30) ?low_aspect)
                                      (case (>= ?volatility.target 0.70)        ?volatility)))
  (record dispositional    1    (cond (case (matches ?girth.target [k fat|thin]) ?girth)
                                      (case (= ?height.target [k short])       ?height))))

(think bonded-incident-insult
  (cooldown 1 m try-once)
  (rng-stream incidents)

  (role @self {@self politeness ?politeness}
              {@self narcissism ?narcissism} 
    (role ?victim {?victim isa [k human], condition [k alive]}
                  {@self (closeness-labels acquaintance) ?victim /ever}
                  (spatial ?victim co-located @self)

      ; Anger load is @self-only and (emotion-load) is not cheap - compute it ONCE and
      ; derive the ladder context from it, so neither the (when) nor the per-row
      ; select-row (when) re-evaluates it.
      (bind (emotion-load [k anger]) ?emo_load)
      (bind (if (> ?emo_load 0.5) (then displaced_anger) (else dispositional)) ?emo_ctx)

      ; The actor's impulse (dispositional base + displaced anger) and the victim-
      ; stance gate are both non-belief (chance) tests, so they live in (when).
      (when (and (chance (+ (* (crime-scale) 0.06
                               (- 1.0 ?politeness)
                               ?narcissism)
                            (* (crime-scale) 0.08 ?emo_load)))
                 (chance (+ 0.10
                            (* 0.15 (+ (prob {@self dislike ?victim})
                                       (prob {@self disdain ?victim})))
                            (* 0.30 (+ (prob {@self detest  ?victim})
                                       (prob {@self despise ?victim})))))))

      ; The mockable material, read per victim - each tolerant, so a missing read is
      ; just @fail (no abort). Each capture holds the whole belief.
      (do
        (tolerate (any {?victim girth ?}):?girth)
        (tolerate (any {?victim height ?}):?height)
        (tolerate (any {?victim sobriety ?}):?sobriety)
        (tolerate (lowest /target {?victim politeness|industriousness|orderliness|compassion ?}):?low_aspect)
        (tolerate (any {?victim volatility ?}):?volatility)
        (tolerate (any {?victim class-situation [k lower]}):?class-situation)
        (tolerate (any {?victim prestige ?}):?prestige))

      ; Compose the barb: context is the anger-driven ladder choice; ?barb the
      ; belief @self voices. No material in that context -> nothing binds -> silence.
      (select-row (table barb_ladder)
        (bind context ?ctx)
        (bind rank ?rank)
        (bind barb-eval ?barb)
        (when (= ?ctx ?emo_ctx))
        (score (if (is-belief ?barb) (then ?rank) (else 0)))
        (policy roulette))

      (declare-utility want)

      (effects
        (maintain-proposal {@self tell (utterable-msg [/msg-class insult] ?barb) ?victim})))))
