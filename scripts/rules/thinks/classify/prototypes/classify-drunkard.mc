; drunkard: a standing craving for drink IS the dependency.
(think classify-drunkard
  ; The drunkard toggle mints when a craving is present and REMOVES when it is forgotten
  ; (rehabilitation). The gate's prototype disjunct keeps the rule eligible across the
  ; removing fire.
  (rng-stream behaviour)
  (role @self (or {@self craving ?}
                  {@self prototype [k prototype drunkard]})
    (effects
      (mint-band {@self prototype} (prob {@self craving ?})
        [k prototype drunkard] 0.5))))
