; gamble - the APPROACH/EXECUTE acts of the gambling lane (npc-act). Desire (gamble_urge) is in npc-think/gamble_urge.hs.
; (Split from the original lane file in the npc-think/npc-act reorg.)

(hsim-event seek_game
  (intra-day)
  (when (and (has-goal play_game)
             (not (at-place-kind [k building pub]))))
  (utility 30)
  (effects
    (go @self (venue [k building pub]))))

(hsim-event gamble_act
  (intra-day)
  (when (and (has-goal play_game)
             (at-place-kind [k building pub])))
  (utility 30)
  (effects
    (act gamble_episode 90)))

(hsim-event gamble_episode
  (schedule (completion-only))
  (effects
    ; gambling_addiction is the standing DISPOSITION to gamble (a state, not
    ; an act), accumulating exactly as intoxication does (~2 onsets to morbid);
    ; the sobriety + wealth classifiers read it graded.
    (set-attr @self gambling_addiction
              (min 1 (+ (attr @self gambling_addiction) 0.5)))
    (end-goal {@self play_game})
    ))
