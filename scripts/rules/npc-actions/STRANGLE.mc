; ----------------------------------------------------------------------------
; STRANGLE - one strangling grip on ?foe, LETHAL: a landed grip kills and leaves a ligature
; mark, a slipped one bruises the throat and may still kill (blow_succumb_prob), and
; either hurts. Witnesses SEE it (obs); blame is runtime, never on the grip.
; ----------------------------------------------------------------------------

(npc-action {@self STRANGLE ?foe}
  (motor body legs)
  (track-skill-level [k martial])
  (obs) (theme violent-to) (construed-act harm-act) (contradicts safety) (duration (seconds 1 min))
  (effects
    (switch (land-blow)
      (on hit   (yield-evidence ?foe [k head] [k ligature-mark])
                (inflict-pain ?foe (strangle_hit_pain))
                (kill-blow ?foe strangle))
      (on graze (yield-evidence ?foe [k head] [k bruise])
                (inflict-pain ?foe (strangle_graze_pain))
                (if (chance (blow_succumb_prob)) (then (kill-blow ?foe strangle)))))
    (set-outcome {@self STRANGLE ?foe} /succ)))
