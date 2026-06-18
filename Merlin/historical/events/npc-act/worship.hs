; worship - the APPROACH/EXECUTE acts of the churchgoing lane (npc-act). Desire (feel_devout) is in npc-think/feel_devout.hs.
; (Split from the original lane file in the npc-think/npc-act reorg.)

(hsim-event seek_church
  (intra-day)
  (nl   "@self sets out for church")
  (when (and (has-goal worship)
             (not (self-at [k building church]))))
  (utility 30)
  (effects
    (go @self (venue [k building church]))))

(hsim-event attend_church
  (intra-day)
  (nl   "@self attends the service")
  (when (and (has-goal worship)
             (self-at [k building church])))
  (utility 30)
  (effects
    (act worship_episode 90)))

(hsim-event worship_episode
  (schedule (chain-only))
  (nl   "@self worships at church")
  (effects
    (go-to-church @self)
    (clear-goal @self worship)
    (log _worship_episode @self)))
