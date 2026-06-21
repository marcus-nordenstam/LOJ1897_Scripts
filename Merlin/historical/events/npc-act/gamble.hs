; gamble - the APPROACH/EXECUTE acts of the gambling lane (npc-act). Desire (gamble_urge) is in npc-think/gamble_urge.hs.
; (Split from the original lane file in the npc-think/npc-act reorg.)

(hsim-event seek_game
  (intra-day)
  (nl   "@self sets out to gamble")
  (when (and (has-goal play_game)
             (not (self-at [k building pub]))))
  (utility 30)
  (effects
    (go @self (venue [k building pub]))))

(hsim-event gamble_act
  (intra-day)
  (nl   "@self gambles")
  (when (and (has-goal play_game)
             (self-at [k building pub])))
  (utility 30)
  (effects
    (act gamble_episode 90)))

(hsim-event gamble_episode
  (schedule (completion-only))
  (nl   "@self gambles at the table")
  (effects
    (gamble @self)
    (clear-goal @self play_game)
    (log _gamble_episode @self)))
