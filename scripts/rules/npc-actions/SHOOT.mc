; ----------------------------------------------------------------------------
; SHOOT - one shot at ?foe, LETHAL: a landed shot through the head kills, a graze wounds
; the hand and may still kill (blow_succumb_prob), and either hurts. Witnesses SEE it
; (obs); blame is runtime, never on the shot.
; ----------------------------------------------------------------------------

(npc-action {@self SHOOT ?foe}
  (motor body legs)
  (track-skill-level [k martial])
  (obs) (theme violent-to) (construed-act harm-act) (contradicts safety) (duration (seconds 1 min))
  (effects
    (switch (land-blow)
      (on hit   (yield-evidence ?foe [k head] [k puncture-wound])
                (inflict-pain ?foe (shot_hit_pain))
                (kill-blow ?foe shoot))
      (on graze (yield-evidence ?foe [k right-hand] [k puncture-wound])
                (inflict-pain ?foe (shot_graze_pain))
                (if (chance (blow_succumb_prob)) (then (kill-blow ?foe shoot)))))
    (set-outcome {@self SHOOT ?foe} /succ)))
