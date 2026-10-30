; DRINK - the drink, proposed by go-drink once he stands in a bar-room. The {@self DRINK}
; act-belief IS the episodic drinking memory days-since-last and the sobriety classifier read.

(action {@self DRINK}:?DRINK
  (motor body)
  (duration (seconds 90 min))
  (init (check (stands-in-room [k bar-room])))
  (cap-outcome succ)
  (effects
    ; Intoxication accumulates as a lifetime-drinking proxy (v1 - no decay), a share of the
    ; drink with every tick of it; the sobriety classifier reads the attr back. Locationless by
    ; design: pub co-presence comes from the itinerary, so no false "drank at the Crown".
    (set-attr @self intoxication
              (min 1.0 (+ (attr @self intoxication)
                          (* 0.34 (/ (act-dt) (max (act-dt) (act-length)))))))
    ; Dependence onset, once the drink is down: only an established heavy drinker is at risk,
    ; scaled by temperament (weak restraint + negative-affect self-medication). Idempotent.
    (if (and (>= (act-elapsed) (act-length))
             (>= (attr @self intoxication) 0.5)
             (chance (* 0.06
                        (+ 0.4 (* 1.6 (- 1.0 (attr @self industriousness))))
                        (+ 0.6 (* 0.8 (attr @self withdrawal))))))
        (then (begin-belief {@self craving [k alcohol]})))))
