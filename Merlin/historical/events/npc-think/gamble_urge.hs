; ----------------------------------------------------------------------------
; The GAMBLING lane - the three-stage intra-day lane (4.13.15), the twin of get_drunk:
;
;   (a) DESIRE   gamble_urge (long-term-think) - low industriousness (a want of
;       self-discipline) takes to (or sinks deeper into) gambling; on a hit it
;       mints the standing goal {@self goal {@self play_game}}.
;   (b) APPROACH seek_game   (short-term-think) - holds the goal but is not at a pub ->
;       a (go) travel act to a pub (the gambling venue).
;   (c) EXECUTE  gamble_act  (short-term-think) - at a pub with the goal -> the durative
;       gamble act; its completion bumps `gambling_addiction` (capped at morbid,
;       exactly as get_drunk bumps `intoxication`) and clears the goal.
;
; Gambling ACCUMULATES (each fire deepens the addiction ~0.5 -> ~2 fires to morbid),
; so the desire is a low-rate repeat; the addiction depth is the running total.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-npc-behaviour gamble_urge
  (long-term-think)
  (rng-stream behaviour)
  (roles
    (role @self (template grown)))
  (when (chance (* 0.0005 (+ 0.6 (* 0.8 (- 1.0 (attr @self industriousness)))))))
  (effects
    (begin-goal {@self play_game})))

