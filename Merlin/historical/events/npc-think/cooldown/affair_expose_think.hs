(include "../../../definitions/roles.hs")

(npc-think affair_expose
  (cooldown 1 m)
  (rng-stream incidents)

  (role @self (adult @self) (believes {@self lover ?}))
  (role ?cheater (any_human ?cheater)
    (believes {@self lover ?cheater})
    (select (policy first-match)))

  (when (chance (* 0.3 (infidelity-disposition @self))))

  (effects
    (debug-print "EXPOSE_FIRE @self cheater=?cheater")
    (if (is-entity (spouse-of ?cheater)) (then (debug-print "EXP_SP @self")))
    (if (is-entity (home-of ?cheater)) (then (debug-print "EXP_HOME @self")))
    (if (is-entity (home-of ?cheater))
        (then
          (debug-print "EXPOSE_SENT @self cheater=?cheater")
          (spawn-letter [k denunciation_letter]
                        (written-msg {?cheater lover @self} signed)
                        (home-of ?cheater))))))
