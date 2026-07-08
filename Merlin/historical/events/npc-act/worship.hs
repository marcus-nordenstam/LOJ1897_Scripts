; worship - the APPROACH/EXECUTE acts of the churchgoing lane (npc-act). Desire (feel_devout) is in npc-think/feel_devout.hs.
; (Split from the original lane file in the npc-think/npc-act reorg.)

(hsim-npc-behaviour seek_church
  (short-term-think)
  (when (and (has-goal worship)
             (not (at-place-kind [k building church]))))
  (utility 30)
  (effects
    (bind (venue [k building church]) ?go_dest) (begin-act {@self go ?go_dest})))

(hsim-npc-behaviour attend_church
  (short-term-think)
  (when (and (has-goal worship)
             (at-place-kind [k building church])))
  (utility 30)
  (effects
    (begin-act {@self worship} 90 worship_episode)))

(hsim-npc-behaviour worship_episode
  (on-completion)
  (effects
    ; The standing piety marker the classifier reads (v1 piety is binary;
    ; idempotent at commit). Minted about the church the NPC is ACTUALLY at -
    ; the churchgoing lane travelled them there, so this is real co-presence,
    ; not a picked location.
    (bind (current-building @self) ?church)
    (if (is-entity ?church)
        (begin-belief {@self worship ?church}))
    (end-goal {@self worship})
    ))
