; ----------------------------------------------------------------------------
; DRINK ?fluid - a drink: ?fluid, the drink a glass he holds grips, goes down and the glass is
; empty (drink.ms2: his hand grips the glass, the glass grips the fluid). go-drink proposes a few,
; a session's. The {@self DRINK ?fluid} act-belief is the drinking memory days-since-last and the
; sobriety classifier read; an alcoholic drink adds to his intoxication, and an established heavy
; drinker may come to crave it.
; ----------------------------------------------------------------------------

; What one drink of an alcoholic drink adds to his intoxication.
(define-macro intoxication-per-drink () 0.11)

(action {@self DRINK ?fluid}:?DRINK
  (construed-act sensual-act)
  (tar [k fluid] @object)
  (obs)
  (motor mouth)
  (duration (seconds 10 min))
  (init (check (= (spatial (spatial ?fluid gripped-by) held-by) @self)))
  (cap-outcome succ)
  (effects
    (if (>= (act-elapsed) (act-length))
        (then
          (if (is-a ?fluid [k alcoholic-drink])
              (then
                (set-attr @self intoxication (min 1.0 (+ (attr @self intoxication) (intoxication-per-drink))))
                ; Dependence onset: only an established heavy drinker is at risk, scaled by
                ; temperament (weak restraint + negative-affect self-medication). Idempotent.
                (if (and (>= (attr @self intoxication) 0.5)
                         (chance (* 0.02
                                    (+ 0.4 (* 1.6 (- 1.0 (attr @self industriousness))))
                                    (+ 0.6 (* 0.8 (attr @self withdrawal))))))
                    (then (begin-belief {@self craving [k alcohol]})))))
          (destroy-entity ?fluid)))))
