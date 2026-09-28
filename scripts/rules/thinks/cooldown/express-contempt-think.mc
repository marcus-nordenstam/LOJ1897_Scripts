; ----------------------------------------------------------------------------
; express-contempt (think). The DELIBERATE, attitude-driven insult - the
; considered counterpart to the impulsive bonded-incident-insult. Where that is a
; trait roll (low politeness x narcissism), this is GATED on the attitude itself:
; @self holds ?victim in deep contempt (the esteem stance has reached the
; `despise` band) and occasionally lets it show as a cutting remark. This fills a
; gap the impulsive path leaves: a NON-narcissist who despises someone never
; insults them under the narcissism gate. Contempt finds expression regardless of
; impulsiveness - the driver is the contempt, modulated only by callousness (low
; compassion expresses it readily; the compassionate hold it in).
;
; A SPOKEN cut - the despised must be co-present to hear it; the barb (voiced as
; the reason he is despised: his moral record) rides the witnessed SAY. Open
; contempt is a considered, adult act - minors do not deliver it.
; ----------------------------------------------------------------------------


; cold_contempt: voice the REASON he is despised - his moral record first, then
; his drink, his affairs, his want of decorum. Each capture is a whole belief
; @self holds about ?victim, captured per victim by the (do ...) block below.
(define-table contempt_ladder
  (capture ?misdeed ?sobriety ?lover ?decorum)
  (fields context        rank  barb-eval)

  (record cold_contempt  4  ?misdeed)
  (record cold_contempt  3  (if (<= ?sobriety.target 0.35) (then ?sobriety)))
  (record cold_contempt  2  ?lover)
  (record cold_contempt  1  (if (<= ?decorum.target 0.35) (then ?decorum))))

(think express-contempt
  (cooldown 1 m try-once)
  (rng-stream incidents)

  ; Open contempt is a considered, adult act - minors do not deliver it.
  (role @self {@self compassion ?compassion}
              {@self age-band [k young-adult|middle-aged|mature|elderly]}
    (role ?victim {?victim isa [k human], condition [k alive]}
                  ; @self holds ?victim in deep contempt (esteem `despise`, the
                  ; floor esteem band - so the exact-band belief IS "esteem at
                  ; least despise"), read as an EXPLICIT verb-state belief.
                  {@self despise ?victim}
                  ; A cutting remark must be heard: the despised is co-present.
                  (spatial ?victim co-located @self)

      ; How readily the contempt surfaces: the callous (low compassion) cut openly; the
      ; compassionate restrain it. A non-belief (chance) gate, rolled per victim at
      ; firing, so it lives in (when) - not as a role criterion (would not be cacheable).
      (when (chance (* (crime-scale) 0.04 (- 1.0 ?compassion))))

      ; The moral material @self can voice, read per victim - each tolerant.
      (do
        (tolerate (any {?victim jilt|disinherit ? /ever}):?misdeed)
        (tolerate (any {?victim sobriety ?}):?sobriety)
        (tolerate (any {?victim lover ?}):?lover)
        (tolerate (any {?victim decorum ?}):?decorum))

      (select-row (table contempt_ladder)
        (bind context ?ctx)
        (bind rank ?rank)
        (bind barb-eval ?barb)
        (when (= ?ctx cold_contempt))
        (score (if (is-belief ?barb) (then ?rank) (else 0)))
        (policy roulette))

      (utility want)

      (effects
        (maintain-proposal {@self SAY (utterable-msg [/msg-class insult] ?barb) ?victim})))))
