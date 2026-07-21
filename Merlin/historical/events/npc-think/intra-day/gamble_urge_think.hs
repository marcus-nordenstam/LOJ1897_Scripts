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
;     never gamble; the addicted are pulled in deep. The drive holds the ABSTRACT
;     {@self play_game} goal; gamble_act drains it on completion.
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

; The DRIVE. The ONLY place the pressure is computed. A 10-day cooldown re-checks the
; urge; the (days-since-last) fire-gate mints the standing {@self play_game} desire only
; when genuinely due; the addiction-amplified utility competes it; and gamble_act drains
; the goal on completion (there is no excl_goal_sweep to retract it).
(npc-think gamble_urge
  (schedule cooldown 10 d)
  (if-blocked hold)
  (role @self (grown @self))
  ; ONSET is rare and susceptibility-scaled: the disciplined seldom take a first flutter
  ; (low industriousness -> higher onset), but once any gambling_addiction has taken hold
  ; the pull is ALWAYS felt (the spiral pulls the addicted back every window). This gate is
  ; load-bearing: the {@self play_game} goal is persistent and gets fulfilled even at low
  ; utility during idle time, so WITHOUT rate-limiting onset here every adult would take a
  ; first gamble and the whole town would spiral into addiction.
  (when (and (>= (days-since-last @self play_game) 10)
             (or (> (attr @self gambling_addiction) 0)
                 (chance (* 0.02 (- 1 (attr @self industriousness)))))))
  (utility (* (- 1 (attr @self industriousness))                    ; susceptibility (0 = disciplined)
              (+ 2 (* 22 (attr @self gambling_addiction)))          ; onset 2 -> morbid 24 (below leisure)
              (min (* (days-since-last @self play_game) 0.04) 1.0))) ; slow craving modulator [0,1]
  (effects (begin-goal {@self play_game})))

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
