; give_alms - the almsgiving ACT-BODY (npc-action). The pressure think that proposes
; it is npc-think/feel_charitable.hs. The {@self give_alms <church>} act-belief -
; begun at commit, ended by (end-act) at completion - IS the episodic memory
; days-since-last reads. No aim, no end-goal.

(npc-action give_alms_act
  (act {@self give_alms ?church})
  (duration 60)
  (act-effects
    ; A punctual {@self give <sum>} act-record (born ended - a begin would leave
    ; the give ongoing forever, and a later identical sum would trip the self-act
    ; contradiction tripwire). The generosity classifier reads it.
    (begin-ended-belief {@self give (random-int 10 100)})
    (end-act {@self give_alms ?church})))
