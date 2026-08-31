; ----------------------------------------------------------------------------
; The GAMBLING lane (B4 pressure model). Two thinks:
;   gamble_urge (drive): gambling is a VICE, so its pressure is ADDICTION-driven,
;     not "overdue"-driven (a man who never gambled feels no pull). A 10-day cooldown
;     re-checks the urge; the (days-since-last {@self PLAY_GAME /ever}) fire-gate mints the
;     standing {@self PLAY_GAME} drive only when genuinely due; the utility is
;     susceptibility (low industriousness) x an amplifier that starts tiny - a rare
;     deep-idle ONSET draw - and SPIRALS with gambling_addiction, x a days-since-last
;     craving modulator clamped to [0,1] (so a never-gambler's sentinel days-since
;     never blows the pressure up, and gambling paces the recurrence). The disciplined
;     never gamble; the addicted are pulled in deep. The drive OWNS the ABSTRACT
;     {@self PLAY_GAME} goal: once gamble_act resets days-since-last the (when) drops,
;     ending it - the act only accrues the addiction, never the goal.
;   gamble_go (maintenance): not at a pub, but knows one - roulette the nearest known
;     pub and head to it via the generic enter chain (§5.11). It roulettes a pub once and
;     holds {@self enter ?venue} so it STICKS with that pub (no re-roulette while walking);
;     on arrival (spatial @self building ?venue) the (when) drops and cease-effects end the enter-goal.
;     The enter chain steps the gambler INSIDE.
;   gamble_at_pub (terminal): AT a pub, the standing {@self PLAY_GAME} drive is PROPOSED
;     ({@self PLAY_GAME}), promoting to gamble_act (npc-act/gamble_act.hs). The proposed
;     label no longer auto-promotes, so this is the only place the act runs.
; No known pub -> no gamble_go role -> no gambling.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

; The DRIVE, and the MAINTENANCE rule that owns the play_game goal end to end. A 10-day
; cooldown re-checks the urge; the (days-since-last) gate holds the standing {@self PLAY_GAME}
; desire while genuinely due; the addiction-amplified utility competes it. The MINTER owns
; un-minting: once gamble_act completes, days-since-last resets, the (when) drops,
; ending {@self PLAY_GAME}. The act itself only accrues the addiction and ends
; its OWN act-belief, never the goal (like drink_act).
(npc-think gamble_urge
  (cooldown 10 d)
  (role @self (grown @self))
  ; ONSET is rare and susceptibility-scaled: the disciplined seldom take a first flutter
  ; (low industriousness -> higher onset), but once any gambling_addiction has taken hold
  ; the pull is ALWAYS felt (the spiral pulls the addicted back every window). (latch-eval)
  ; rolls the onset (chance) at the fire and LOCKS it once holding, so the held re-check never
  ; re-rolls it (it re-rolls each window until it lands). This gate is load-bearing: WITHOUT
  ; rate-limiting the first flutter here every adult would take a first gamble and the whole
  ; town would spiral into addiction.
  (when (and (>= (days-since-last {@self PLAY_GAME /ever}) 10)
             (or (> (attr @self gambling_addiction) 0)
                 (latch-eval (chance (* 0.02 (- 1 (attr @self industriousness))))))))
  (utility want (* 10 (* (- 1 (attr @self industriousness))                    ; susceptibility (0 = disciplined)
              (+ 2 (* 22 (attr @self gambling_addiction)))          ; onset 2 -> morbid 24 (below leisure)
              (min (* (days-since-last {@self PLAY_GAME /ever}) 0.04) 1.0)))) ; slow craving modulator [0,1]
  (effects       (begin-goal {@self PLAY_GAME}))
  (cease-effects (end-goal   {@self PLAY_GAME})))
