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
    (give-alms @self)
    (end-goal {@self give_alms})
    ))
