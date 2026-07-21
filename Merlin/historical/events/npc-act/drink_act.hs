; drink - the drink ACT-BODY (npc-act). The pressure think that proposes it is
; npc-think/crave_drink.hs (+ relapse.hs for dependents). The {@self drink}
; act-belief - begun at commit, ended by (end-act) at completion - IS the episodic
; drinking memory days-since-last / the sobriety classifier read. No aim, no
; end-goal: the act just does the act; crave_drink ceases because drinking reset
; its pressure.

(npc-act drink_act
  (when (believes {@self drink}))
  (duration 90)
  (act-effects
    ; Intoxication accumulates as a lifetime-drinking proxy (v1 - no decay); the
    ; sobriety classifier reads the attr back. Locationless by design: pub
    ; co-presence comes from the itinerary, so no false "drank at the Crown".
    (set-attr @self intoxication (min 1 (+ (attr @self intoxication) 0.34)))
    ; Dependence onset: only an established heavy drinker is at risk, scaled by
    ; temperament (weak restraint + negative-affect self-medication). Idempotent.
    (if (and (>= (attr @self intoxication) 0.5)
             (chance (* 0.06
                        (+ 0.4 (* 1.6 (- 1 (attr @self industriousness))))
                        (+ 0.6 (* 0.8 (attr @self withdrawal))))))
        (then (begin-belief {@self craving [k alcohol]})))
    ; Public drinking is SEEN: co-present others mint {him drink him} - the
    ; visible-vice evidence observer estimates read. The home drinker generates
    ; no witnesses; concealment is emergent, not simulated. Witnessing is now
    ; engine-side (auto-witness on this obs act at completion), not hand-authored.
    (end-act {@self drink})))
