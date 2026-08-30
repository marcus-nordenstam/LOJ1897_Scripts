(include "../../../definitions/roles.hs")

(npc-think affair_expose
  (cooldown 1 m)
  (rng-stream incidents)

  (role @self (adult @self) {@self lover ?}
              ; @self signs the denunciation - bind his OWN name for "Signed, ..".
              {@self name ?author_name})
  (role ?cheater (any_human ?cheater)
    {@self lover ?cheater}
    ; @self names the cheater in the letter body (a name value, not the object).
    {?cheater name ?cheater_name}
    (select (policy first-match)))

  (when (chance (* 0.3 (infidelity-disposition @self))))

  (utility want)

  (effects
    (debug-print "EXPOSE_FIRE @self cheater=?cheater")
    ; The denunciation exposes the affair to the cheater's WRONGED SPOUSE - the one
    ; party it is meant to reach (they cohabit, so it lands in their shared home pile
    ; and only the spouse reads it). No spouse = no betrayal to expose, so nothing sent.
    (spouse-of ?cheater): ?betrayed
    (if (and (alive ?betrayed) (any {?cheater home ?cheater_home}))
        (then
          (debug-print "EXPOSE_SENT @self cheater=?cheater")
          (post-letter [k denunciation_letter]
                       (nl-written-msg "?cheater_name has taken me as a lover. Signed, ?author_name")
                       ?cheater_home ?betrayed)))))
