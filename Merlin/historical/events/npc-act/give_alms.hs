; give_alms - the APPROACH/EXECUTE acts of the charity lane (npc-act). Desire (feel_charitable) is in npc-think/feel_charitable.hs.
; (Split from the original lane file in the npc-think/npc-act reorg.)

(hsim-npc-behaviour seek_alms_church
  (short-term-think)
  (when (and (has-goal give_alms)
             (not (at-place-kind [k building church]))))
  (utility 30)
  (effects
    (bind (venue [k building church]) ?go_dest) (begin-act {@self go ?go_dest})))

(hsim-npc-behaviour give_alms_act
  (short-term-think)
  (when (and (has-goal give_alms)
             (at-place-kind [k building church])))
  (utility 30)
  (effects
    (begin-act {@self give_alms} 60 alms_episode)))

(hsim-npc-behaviour alms_episode
  (on-completion)
  (effects
    ; A punctual {@self give <sum>} act-record (born ended - a begin would
    ; leave the give ongoing forever and a later identical amount would trip
    ; the self-act contradiction tripwire). The generosity classifier reads it.
    (begin-ended-belief {@self give (random-int 10 100)})
    (end-goal {@self give_alms})
    ))
