; ----------------------------------------------------------------------------
; express_contempt (npc-think). The DELIBERATE, attitude-driven insult - the
; considered counterpart to the impulsive bonded_incident_insult. Where that is a
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

(include "../../../definitions/roles.hs")

; cold_contempt: voice the REASON he is despised - his moral record first, then
; his drink, his affairs, his want of decorum. Each `-rel` var is a whole belief
; @self holds about ?victim, captured per victim by the (do ...) block below.
(define-table contempt_ladder
  (capture ?actrec-rel ?sob-rel ?lover-rel ?dec-rel)
  (fields context        rank  barb_eval)

  (record cold_contempt  4  ?actrec-rel)
  (record cold_contempt  3  (if (<= ?sob-rel.target 0.35) (then ?sob-rel)))
  (record cold_contempt  2  ?lover-rel)
  (record cold_contempt  1  (if (<= ?dec-rel.target 0.35) (then ?dec-rel))))

(npc-think express_contempt
  (cooldown 1 m)
  (rng-stream incidents)

  ; Open contempt is a considered, adult act - minors do not deliver it.
  (role @self
              (adult-age @self))
  (role ?victim (any_human ?victim)
                ; @self holds ?victim in deep contempt (esteem `despise`, the
                ; floor esteem band - so the exact-band belief IS "esteem at
                ; least despise"), read as an EXPLICIT verb-state belief.
                {@self despise ?victim}
                ; A cutting remark must be heard: the despised is co-present.
                (spatial ?victim co-located @self))

  ; How readily the contempt surfaces: the callous (low compassion) cut openly; the
  ; compassionate restrain it. A non-belief (chance) gate, rolled per victim at
  ; firing, so it lives in (when) - not as a role criterion (would not be cacheable).
  (when (chance (* (crime-scale) 0.04 (- 1.0 (attr @self compassion)))))

  ; The moral material @self can voice, read per victim - each tolerant.
  (do
    (tolerate (any {?victim jilt|disinherit ? /ever}):?actrec-rel)
    (tolerate (any {?victim sobriety ?}):?sob-rel)
    (tolerate (any {?victim lover ?}):?lover-rel)
    (tolerate (any {?victim decorum ?}):?dec-rel))

  (select-row (table contempt_ladder)
    (bind context ?ctx)
    (bind rank ?rank)
    (bind barb_eval ?barb-rel)
    (when (= ?ctx cold_contempt))
    (score (if (is-belief ?barb-rel) (then ?rank) (else 0)))
    (policy roulette))

  (utility want)

  (effects
    (maintain-proposal {@self SAY (utterable-msg ?barb-rel (msg_class insult)) ?victim})))
