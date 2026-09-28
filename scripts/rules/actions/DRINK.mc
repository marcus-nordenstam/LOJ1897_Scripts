; drink - the drink ACT-BODY (action), proposed by go-drink in a pub. The {@self DRINK}
; act-belief IS the episodic drinking memory days-since-last and the sobriety classifier read.

(action {@self DRINK}:?DRINK
  (motor body legs)
  (duration (seconds 90 min))
  (init (check (is-a (spatial @self building) [k building pub])))
  (effects
    ; Intoxication accumulates as a lifetime-drinking proxy (v1 - no decay); the
    ; sobriety classifier reads the attr back. Locationless by design: pub
    ; co-presence comes from the itinerary, so no false "drank at the Crown".
    (set-attr @self intoxication (min 1.0 (+ (attr @self intoxication) 0.34)))
    ; Dependence onset: only an established heavy drinker is at risk, scaled by
    ; temperament (weak restraint + negative-affect self-medication). Idempotent.
    (if (and (>= (attr @self intoxication) 0.5)
             (chance (* 0.06
                        (+ 0.4 (* 1.6 (- 1.0 (attr @self industriousness))))
                        (+ 0.6 (* 0.8 (attr @self withdrawal))))))
        (then (begin-belief {@self craving [k alcohol]})))
    ; Public drinking is SEEN: co-present others mint {him drink him} - the
    ; visible-vice evidence observer estimates read. The home drinker generates
    ; no witnesses; concealment is emergent, not simulated. Witnessing is now
    ; engine-side (auto-witness on this obs act at completion), not hand-authored.
    (set-outcome ?DRINK /succ)))
