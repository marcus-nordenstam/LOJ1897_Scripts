; give_alms - the APPROACH/EXECUTE acts of the charity lane (npc-act). Desire (feel_charitable) is in npc-think/feel_charitable.hs.
; (Split from the original lane file in the npc-think/npc-act reorg.)

(hsim-event seek_alms_church
  (intra-day)
  (when (and (has-goal give_alms)
             (not (at-place-kind [k building church]))))
  (utility 30)
  (effects
    (go @self (venue [k building church]))))

(hsim-event give_alms_act
  (intra-day)
  (when (and (has-goal give_alms)
             (at-place-kind [k building church])))
  (utility 30)
  (effects
    (act alms_episode 60)))

(hsim-event alms_episode
  (schedule (completion-only))
  (effects
    ; A punctual {@self give <sum>} act-record (born ended - a begin would
    ; leave the give ongoing forever and a later identical amount would trip
    ; the self-act contradiction tripwire). The generosity classifier reads it.
    (begin-ended-belief {@self give (random-int 10 100)})
    (end-goal {@self give_alms})
    ))
