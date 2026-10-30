; DRINK - the drink, proposed by go-drink once he stands in a bar-room. The {@self DRINK}
; act-belief IS the episodic drinking memory days-since-last and the sobriety classifier read.

(action {@self DRINK}:?DRINK
  (construed-act sensual-act)
  (motor body)
  (duration (seconds 90 min))
  (init (check (stands-in-room [k bar-room])))
  (cap-outcome succ)
  ; All of it when the drink is down, none on an interrupted one. Intoxication accumulates as a
  ; lifetime-drinking proxy (v1 - no decay); the sobriety classifier reads the attr back.
  (effects
    (if (>= (act-elapsed) (act-length))
        (then (set-attr @self intoxication (min 1.0 (+ (attr @self intoxication) 0.34)))
              ; Dependence onset: only an established heavy drinker is at risk, scaled by
              ; temperament (weak restraint + negative-affect self-medication). Idempotent.
              (if (and (>= (attr @self intoxication) 0.5)
                       (chance (* 0.06
                                  (+ 0.4 (* 1.6 (- 1.0 (attr @self industriousness))))
                                  (+ 0.6 (* 0.8 (attr @self withdrawal))))))
                  (then (begin-belief {@self craving [k alcohol]})))))))
