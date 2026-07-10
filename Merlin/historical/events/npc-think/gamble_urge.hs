; ----------------------------------------------------------------------------
; The GAMBLING lane (B4 pressure model). ONE think:
;   gamble_urge (npc-think): gambling is a VICE, so its pressure is ADDICTION-
;     driven, not "overdue"-driven (a man who never gambled feels no pull). The
;     utility is susceptibility (low industriousness) x an amplifier that starts
;     tiny - a rare deep-idle ONSET draw - and SPIRALS with gambling_addiction, x
;     a days-since-last craving modulator clamped to [0,1] (so a never-gambler's
;     sentinel days-since never blows the pressure up, and gambling paces the
;     recurrence). The disciplined never gamble; the addicted are pulled in deep.
;     At a pub -> the play_game act-goal there; else -> a `go` sub-act-goal.
;   gamble_act (npc-act, gamble.hs): bumps gambling_addiction (the amplifier it
;     feeds back into), ends the act. No aim, no end-goal.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-think gamble_urge
  (short-term-think)
  (role @self (grown @self))
  ; The nearest pub the NPC KNOWS (role-cast; no known pub -> no fire).
  (role ?venue [k building pub] (prefer (near @self ?venue)) (policy weighted))
  (when (>= (days-since-last @self play_game) 10))
  (utility (* (- 1 (attr @self industriousness))                    ; susceptibility (0 = disciplined)
              (+ 2 (* 22 (attr @self gambling_addiction)))          ; onset 2 -> morbid 24 (below leisure)
              (min (* (days-since-last @self play_game) 0.04) 1.0))) ; slow craving modulator [0,1]
  (effects (propose-venue-act ?venue play_game)))
