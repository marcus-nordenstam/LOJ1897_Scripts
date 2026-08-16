; give_alms - the almsgiving ACT-BODY (npc-action). The pressure think that proposes
; it is npc-think/feel_charitable.hs. The {@self GIVE_ALMS <church>} act-belief -
; begun at commit, ended by (set-outcome {..} succ) at completion - IS the episodic memory
; days-since-last reads. No aim, no end-goal.

(npc-action {@self GIVE_ALMS ?church}
  (duration 60)
  (effects
    ; A punctual {@self give <sum>} act-record (born ended - a begin would leave
    ; the give ongoing forever, and a later identical sum would trip the self-act
    ; contradiction tripwire). The generosity classifier reads it.
    (begin-ended-belief {@self give (random-int 10 100)})
    (set-outcome {@self GIVE_ALMS ?church} succ)))
