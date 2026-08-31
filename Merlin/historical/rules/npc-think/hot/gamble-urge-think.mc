; ----------------------------------------------------------------------------
; The GAMBLING lane (B4 pressure model). Three thinks:
;   gamble_urge (drive): gambling is a VICE, so its pressure is ADDICTION-driven,
;     not "overdue"-driven (a man who never gambled feels no pull). A 10-day cooldown
;     re-checks the urge; the (days-since-last @self PLAY_GAME) fire-gate mints the
;     standing {@self PLAY_GAME} drive only when genuinely due; the utility is
;     susceptibility (low industriousness) x an amplifier that starts tiny - a rare
;     deep-idle ONSET draw - and SPIRALS with gambling-addiction, x a days-since-last
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

; MAINTENANCE - not at a pub, but knows one: head to it via the generic enter chain
; (§5.11). It roulettes a pub once and holds {@self enter ?venue} so it STICKS with that
; pub (no re-roulette while walking); on arrival (spatial @self building ?venue) the (when) drops and
; cease-effects end the enter-goal. The enter chain steps the gambler INSIDE the pub, so
; at-place-kind then holds and gamble_at_pub proposes {@self PLAY_GAME}.
(npc-think gamble_go
  (goal {@self PLAY_GAME})
  (role @self (grown @self))
  (role ?venue [k building pub] (select (score (near @self ?venue)) (policy roulette)))
  (when (not (spatial @self building ?venue)))
  (effects (maintain-proposal {@self enter ?venue})))

; TERMINAL step (act_body_purification): the gamble act is now PROPOSED, guarded by being AT a
; pub, not promoted by the bare {@self PLAY_GAME} goal. Because `play_game` is a proposed label
; that goal no longer competes (it still persists + drives gamble_go) - so the gamble act promotes
; ONLY here, ONLY at a pub. The proposal inherits the addiction-amplified drive from the
; {@self PLAY_GAME} goal it /causes (via the (goal ...) gate).
(npc-think gamble_at_pub
  (goal    {@self PLAY_GAME})
  (when    (is-a (spatial @self building) [k building pub]))
  (effects (maintain-proposal {@self PLAY_GAME})))
