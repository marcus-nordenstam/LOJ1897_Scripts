; ----------------------------------------------------------------------------
; The DRINKING lane - the reference three-stage cascade (4.13 (b)):
;
;   (a) DESIRE   crave_drink   (sim-window-start) - the multi-causal risk model
;       decides WHO wants to drink to excess today; on a hit it mints the
;       standing goal {@self goal {@self drink}}. No act, no venue - just the want.
;   (b) APPROACH seek_drink    (intra-day) - holds the drink goal but is nowhere it
;       can drink -> a (go) travel act to a PUB (the social drinking venue).
;   (c) EXECUTE  drink         (intra-day) - holds the drink goal AND is somewhere
;       it can drink (a pub, or its own home) -> the durative drink act; its
;       completion (drink_episode) bumps intoxication, rolls the slide into
;       dependence, and CLEARS the goal so the desire does not re-fire.
;
; The "drank at the Crown" whereabouts is no longer minted by hand: the NPC is
; physically AT the venue when the stepper's completion-pass self-perception
; stamps {@self location <room>} at the real instant.
;
; INTERIM (b1): the intra-day events self-gate on free time (not in/near a shift,
; daytime/evening) so they fire only when the day-shape would otherwise idle. (b2)
; replaces those hand-gates with a situational (utility ...) competition.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

; (a) DESIRE - window-start craving appraisal. Risk = vulnerability x environment /
; protection (low industriousness/politeness = disinhibition, volatility = reactive,
; withdrawal = self-medication, enthusiasm = social; low wealth = stress; piety +
; belonging = protection). Already-dependent NPCs are excluded (relapse casts them).
(hsim-event crave_drink
  (sim-window-start)
  (rng-stream behaviour)

  (roles
    (role ?npc (template old_human)
               (not (= (belief-target ?self craving) [k alcohol]))
               (chance
                 (* 0.014                                                  ; base daily rate
                    (+ 0.55 (* 0.90 (- 1.0 (attr ?self industriousness)))) ; low industriousness
                    (+ 0.65 (* 0.70 (- 1.0 (attr ?self politeness))))      ; low politeness
                    (+ 0.70 (* 0.60 (attr ?self volatility)))              ; reactive drinking
                    (+ 0.70 (* 0.60 (attr ?self enthusiasm)))              ; social drinking
                    (+ 0.70 (* 0.60 (attr ?self withdrawal)))              ; self-medication
                    (- 1.5 (situation ?self wealth))                      ; low wealth -> stress
                    (- 1.5 (situation ?self piety))                       ; low piety -> less protection
                    (- 1.5 (situation ?self belonging))))))               ; low belonging -> less protection

  (effects
    (goal ?npc drink)))

; (b) APPROACH - hold the goal, nowhere to drink: set out for a pub. drink-venue
; picks a same-town pub; k_fail (no pub reachable) means the rule does not fire and
; the goal simply waits.
(hsim-event seek_drink
  (intra-day)
  (nl   "?self sets out for a drink")
  (when (and (has-goal drink)
             (not (can-drink ?self))
             (not (in-work-hours ?self))
             (not (work-starts-soon ?self))
             (>= (now-hour) 6)
             (< (now-hour) 22)))
  (effects
    (go ?self (drink-venue ?self))))

; (c) EXECUTE - hold the goal and at a place with drink (a pub, or home): the
; durative drink act.
(hsim-event drink
  (intra-day)
  (nl   "?self drinks")
  (when (and (has-goal drink)
             (can-drink ?self)
             (not (in-work-hours ?self))
             (not (work-starts-soon ?self))
             (>= (now-hour) 6)
             (< (now-hour) 22)))
  (effects
    (act drink_episode 90)))

; The COMPLETION of the drink act (chain-only: never seeded, fired only when the
; act lands a duration later, in the serial completion pass). Applies the real
; effects + clears the goal. Implicit actor: the act's owner is bound as ?self.
(hsim-event drink_episode
  (schedule (chain-only))
  (nl   "?self has drunk to excess")
  (effects
    (get-drunk ?self)
    (risk-dependence ?self)
    (clear-goal ?self drink)
    (log _drink_episode ?self)))
