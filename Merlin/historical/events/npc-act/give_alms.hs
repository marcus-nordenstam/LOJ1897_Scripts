; give_alms - the APPROACH/EXECUTE acts of the charity lane (npc-act). Desire (feel_charitable) is in npc-think/feel_charitable.hs.
; (Split from the original lane file in the npc-think/npc-act reorg.)

(hsim-event seek_alms_church
  (intra-day)
  (nl   "@self sets out to give alms")
  (when (and (has-goal give_alms)
             (not (at-place-kind [k building church]))))
  (utility 30)
  (effects
    (go @self (venue [k building church]))))

(hsim-event give_alms_act
  (intra-day)
  (nl   "@self gives alms")
  (when (and (has-goal give_alms)
             (at-place-kind [k building church])))
  (utility 30)
  (effects
    (act alms_episode 60)))

(hsim-event alms_episode
  (schedule (completion-only))
  (nl   "@self gives alms at the church")
  (effects
    (give-alms @self)
    (clear-goal @self give_alms)
    (log _alms_episode @self)))
