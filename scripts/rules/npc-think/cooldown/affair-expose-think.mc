(include "../../../definitions/roles.mc")

(npc-think affair_expose
  (cooldown 1 m)
  (rng-stream incidents)

  (role @self {@self age-band [k young-adult|middle-aged|mature|elderly]} {@self lover ?}
                   ; @self signs the denunciation - bind his OWN name for "Signed, ..".
              {@self name ?author_name}
    (role ?cheater {?cheater isa [k human], condition [k alive]}
      {@self lover ?cheater}
      ; @self names the cheater in the letter body (a name value, not the object).
      {?cheater name ?cheater_name}
      (select (policy first-match))

      (utility want)

      (role ?my-home {@self home ?my-home}

        ; Make the paper, pen it, post it - three deeds, each reading the world for what is done.
        (stable-or
          (try
            (role ?ltr [k denunciation-letter] (spatial ?ltr co-located @self)
                                               {@self WRITE ?ltr ? /succ}
                                               -{@self send-mail ?ltr ? /succ}
              (role ?out [k outgoing-mail-stack] (spatial ?out building ?my-home)
                (effects
                  (check (substantial (attr ?ltr writing)))
                  (check (substantial (attr ?ltr destination)))
                  (maintain-proposal {@self send-mail ?ltr ?out})))))

          ; The denunciation exposes the affair to the cheater's WRONGED SPOUSE - the one party it
          ; is meant to reach (they cohabit, so it lands in their shared pile and only the spouse
          ; reads it). No spouse, no betrayal to expose, and the gate simply never opens.
          (try
            (role ?ltr [k denunciation-letter] (spatial ?ltr co-located @self)
                                               (unsubstantial (attr ?ltr writing))
              (when (spouse-of ?cheater): ?betrayed
                    (alive ?betrayed)
                    {?betrayed name ?betrayed-name}
                    {?cheater home ?cheater-home}
                    {?cheater-home address ?cheater-address})
              (effects
                (maintain-proposal
                  {@self write-doc ?ltr
                         (written-msg [/addressee ?betrayed-name /address ?cheater-address /author ?author_name]
                                      {?cheater_name lover @i})}))))

          (try
            (when (chance (* 0.3 (infidelity-disposition @self))))
            (effects (maintain-proposal {@self CREATE-ENTITY [k denunciation-letter]}))))))))
