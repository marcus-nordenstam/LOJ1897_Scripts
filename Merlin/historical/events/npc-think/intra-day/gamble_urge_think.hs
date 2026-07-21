; ----------------------------------------------------------------------------
; The GAMBLING lane (B4 pressure model). Two thinks:
;   gamble_urge (drive): gambling is a VICE, so its pressure is ADDICTION-driven,
;     not "overdue"-driven (a man who never gambled feels no pull). A 10-day cooldown
;     re-checks the urge; the (days-since-last @self play_game) fire-gate mints the
;     standing {@self play_game} drive only when genuinely due; the utility is
;     susceptibility (low industriousness) x an amplifier that starts tiny - a rare
;     deep-idle ONSET draw - and SPIRALS with gambling_addiction, x a days-since-last
;     craving modulator clamped to [0,1] (so a never-gambler's sentinel days-since
;     never blows the pressure up, and gambling paces the recurrence). The disciplined
;     never gamble; the addicted are pulled in deep. The drive OWNS the ABSTRACT
;     {@self play_game} goal: once gamble_act resets days-since-last the (when) drops
;     and the falling edge ends it - the act only accrues the addiction, never the goal.
;   gamble_go (maintenance): not at a pub, but knows one - roulette the nearest known
;     pub and head to it via the generic enter chain (§5.11). On the FIRST fire it
;     mints {@self enter ?venue} and settles into k_holding so it STICKS with that pub
;     (no re-roulette while walking); on arrival (in-building ?venue) the (when) drops
;     and cease-effects end the enter-goal. The enter chain steps the gambler INSIDE.
;   AT a pub: {@self play_game} has no active sub-goal, so it is the leaf and promotes
;     straight to gamble_act (npc-act/gamble_act.hs). No rule needed.
; No known pub -> no gamble_go role -> no gambling.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; The DRIVE, and the MAINTENANCE event that owns the play_game goal end to end. A 10-day
; cooldown re-checks the urge; the (days-since-last) gate holds the standing {@self play_game}
; desire while genuinely due; the addiction-amplified utility competes it. The MINTER owns
; un-minting: once gamble_act completes, days-since-last resets, the (when) drops, and the
; falling edge ends {@self play_game}. The act itself only accrues the addiction and ends
; its OWN act-belief, never the goal (like drink_act).
(npc-think gamble_urge
  (schedule cooldown 10 d)
  (if-blocked hold)
  (role @self (grown @self))
  ; ONSET is rare and susceptibility-scaled: the disciplined seldom take a first flutter
  ; (low industriousness -> higher onset), but once any gambling_addiction has taken hold
  ; the pull is ALWAYS felt (the spiral pulls the addicted back every window). (eval-until-hold)
  ; rolls the onset (chance) at the fire and LOCKS it once holding, so the held re-check never
  ; re-rolls it (it re-rolls each window until it lands). This gate is load-bearing: WITHOUT
  ; rate-limiting the first flutter here every adult would take a first gamble and the whole
  ; town would spiral into addiction.
  (when (and (>= (days-since-last @self play_game) 10)
             (or (> (attr @self gambling_addiction) 0)
                 (eval-until-hold (chance (* 0.02 (- 1 (attr @self industriousness))))))))
  (utility (* (- 1 (attr @self industriousness))                    ; susceptibility (0 = disciplined)
              (+ 2 (* 22 (attr @self gambling_addiction)))          ; onset 2 -> morbid 24 (below leisure)
              (min (* (days-since-last @self play_game) 0.04) 1.0))) ; slow craving modulator [0,1]
  (effects       (begin-goal {@self play_game}))
  (cease-effects (end-goal   {@self play_game})))

; MAINTENANCE - not at a pub, but knows one: head to it via the generic enter chain
; (§5.11). On the FIRST fire it roulettes a pub and mints {@self enter ?venue}, then
; settles into k_holding so it STICKS with that pub (no re-roulette while walking); on
; arrival (in-building ?venue) the (when) drops and cease-effects end the enter-goal. The
; enter chain steps the gambler INSIDE the pub, so {@self play_game} then holds as the
; leaf and gamble_act promotes.
(npc-think gamble_go
  (schedule on-commit)
  (if-blocked hold)
  (goal {@self play_game})
  (role @self (grown @self))
  (role ?venue [k building pub] (select (score (near @self ?venue)) (policy roulette)))
  (when (not (in-building ?venue)))
  (effects       (begin-goal {@self enter ?venue}))
  (cease-effects (end-goal   {@self enter ?venue})))
