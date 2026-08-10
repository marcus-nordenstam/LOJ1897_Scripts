(include "../../../definitions/roles.hs")

(npc-think affair_expose
  (cooldown 1 m)
  (rng-stream incidents)

  (role @self (adult @self) {@self lover ?}
              ; @self signs the denunciation - bind his OWN name for "Signed, ..".
              (believes {@self name ?author_name}))
  (role ?cheater (any_human ?cheater)
    {@self lover ?cheater}
    ; @self names the cheater in the letter body (a name value, not the object).
    (believes {?cheater name ?cheater_name})
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
                        (nl_written_msg "?cheater_name has taken me as a lover. Signed, ?author_name")
                        (home-of ?cheater))))))
