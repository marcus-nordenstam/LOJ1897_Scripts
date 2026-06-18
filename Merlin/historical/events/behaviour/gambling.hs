; ----------------------------------------------------------------------------
; The GAMBLING lane - the three-stage cascade (4.13.15), the twin of get_drunk:
;
;   (a) DESIRE   gamble_urge (sim-window-start) - low industriousness (a want of
;       self-discipline) takes to (or sinks deeper into) gambling; on a hit it
;       mints the standing goal {@self goal {@self play_game}}.
;   (b) APPROACH seek_game   (intra-day) - holds the goal but is not at a pub ->
;       a (go) travel act to a pub (the gambling venue).
;   (c) EXECUTE  gamble_act  (intra-day) - at a pub with the goal -> the durative
;       gamble act; its completion bumps `gambling_addiction` (capped at morbid,
;       exactly as get_drunk bumps `intoxication`) and clears the goal.
;
; Gambling ACCUMULATES (each fire deepens the addiction ~0.5 -> ~2 fires to morbid),
; so the desire is a low-rate repeat; the addiction depth is the running total.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event gamble_urge
  (sim-window-start)
  (rng-stream behaviour)
  (roles
    (role @self (template grown)))
  (when (chance (* 0.0005 (+ 0.6 (* 0.8 (- 1.0 (attr @self industriousness)))))))
  (effects
    (goal @self play_game)))

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
  (schedule (chain-only))
  (nl   "@self gambles at the table")
  (effects
    (gamble @self)
    (clear-goal @self play_game)
    (log _gamble_episode @self)))
