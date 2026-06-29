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
; A mental change (the contempt anchor lands), so npc-think. Fired by the per-NPC
; window-start pass. RELATIONAL: the despise stance is itself a known-person
; cross-pair tie (you despise someone you know), so no separate co-presence gate.
; Open contempt is a considered, adult act - minors do not deliver it (the
; @self age gate), and its low base keeps it rarer than the impulsive insult.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event express_contempt
  (sim-window-start)
  (rng-stream incidents)

  (roles
    ; Open contempt is a considered, adult act - minors do not deliver it.
    (role @self (template any_human)
                (adult-age @self))
    (role ?victim (template any_human)
                  (not (= ?victim @self))
                  ; @self holds ?victim in deep contempt (esteem `despise`, the
                  ; floor esteem band - so the exact-band belief IS "esteem at
                  ; least despise"), read as an EXPLICIT verb-state belief.
                  (believes {@self despise ?victim})))

  ; How readily the contempt surfaces: the callous (low compassion) cut openly; the
  ; compassionate restrain it. A non-belief (chance) gate, rolled per victim at
  ; firing, so it lives in (when) - not as a role criterion (would not be cacheable).
  (when (chance (* 0.04 (- 1.0 (attr @self compassion)))))

  (effects
    (incident-anchor @self insult ?victim /context cold_contempt)
    ))
