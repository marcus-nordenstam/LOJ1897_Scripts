; ----------------------------------------------------------------------------
; hurt (npc-task) - a NON-LETHAL beating. Displaced rage (displace_kill) re-routes an
; unreachable kill onto a weaker innocent as a hurt; hurt reaches the victim and PUNCHes
; them senseless (knockout), never kills. Like the killing tasks, hurt is the actor's
; plan - the PUNCH blows are the (obs) witnessed violent acts that carry the blame, and
; because a beater's PUNCH traces (/caused_by) to no assault on THEM, appraisal keeps its
; wrong-act (the beater is blamed), whereas a defender's identical PUNCH is exonerated.
; The crime is ledgered once the victim is beaten down.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")

(npc-task {@self hurt ?victim}:?hurt-rel
  (tar human)
  (and
    ; REACH: route to the victim's known location, else their home.
    (try
      (when (and (not (spatial ?victim co-located @self))
                 (not (attr-is ?victim awareness unconscious))
                 (spatial ?victim space): ?loc))
      (utility survival)
      (effects (maintain-proposal {@self go ?loc})))
    (try
      (role ?vhome {?victim home ?vhome})
      (when (and (not (spatial ?victim co-located @self))
                 (not (attr-is ?victim awareness unconscious))
                 (unknown (spatial ?victim space))))
      (utility survival)
      (effects (maintain-proposal {@self go ?vhome})))

    ; THE BEATING: PUNCH a co-present, conscious victim.
    (try
      (when (and (spatial ?victim co-located @self)
                 -{?victim condition [k dead]}
                 (not (attr-is ?victim awareness unconscious))))
      (utility survival always-pick)
      (effects (maintain-proposal {@self STRIKE ?victim punch})))

    ; CONCLUDE: the victim is beaten senseless (or already down) - ledger the assault
    ; (method PUNCH, goal hurt) and end the episode.
    (try
      (when (or (attr-is ?victim awareness unconscious)
                {?victim condition [k dead]}))
      (effects
        (crime-ledger-append @self ?victim punch hurt @u @u)
        (set-outcome ?hurt-rel /succ)))))
