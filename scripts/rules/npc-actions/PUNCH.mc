; ----------------------------------------------------------------------------
; PUNCH - one fist blow at ?foe, NON-LETHAL: a landed punch bruises the head and knocks
; the foe out, a graze bruises the torso, and either hurts. Witnesses SEE it (obs); the
; violent-to theme and harm construal are what appraisal and the defender's counter-fight
; read. Blame is runtime (appraisal.cc suppresses wrong-act for a blow that answers a
; violent act on its own actor), never on the blow.
; ----------------------------------------------------------------------------

(npc-action {@self PUNCH ?foe}
  (motor body legs)
  (track-skill-level [k martial])
  (obs) (theme violent-to) (construed-act harm-act) (contradicts safety) (duration (seconds 1 min))
  (effects
    (switch (land-blow)
      (on hit   (yield-evidence ?foe [k head] [k bruise])
                (inflict-pain ?foe (punch_hit_pain))
                (set-attr ?foe awareness [k unconscious]))
      (on graze (yield-evidence ?foe [k torso] [k bruise])
                (inflict-pain ?foe (punch_graze_pain))))
    (set-outcome {@self PUNCH ?foe} /succ)))
