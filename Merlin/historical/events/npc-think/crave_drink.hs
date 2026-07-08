; ----------------------------------------------------------------------------
; The DRINKING lane - the reference three-stage intra-day lane (4.13 (b)):
;
;   (a) DESIRE   crave_drink   (long-term-think) - the multi-causal risk model
;       decides WHO wants to drink to excess today; on a hit it mints the
;       standing goal {@self goal {@self drink}}. No act, no venue - just the want.
;   (b) APPROACH seek_drink    (short-term-think) - holds the drink goal but is nowhere it
;       can drink -> a (go) travel act to a PUB (the social drinking venue).
;   (c) EXECUTE  drink         (short-term-think) - holds the drink goal AND is somewhere
;       it can drink (a pub, or its own home) -> the durative drink act; its
;       completion (drink_episode) bumps intoxication, rolls the slide into
;       dependence, and CLEARS the goal so the desire does not re-fire.
;
; The "drank at the Crown" whereabouts is no longer minted by hand: the NPC is
; physically AT the venue when the stepper's completion-pass self-perception
; stamps {@self location <room>} at the real instant.
;
; The intra-day acts carry a situational (utility 30): they out-compete the
; go-home fallback (1) so a craver in free time heads to the pub, but lose to work
; (80) and sleep (100) when those are eligible - so drinking happens in the day's
; gaps, not during a shift or at night. No hand-coded time gates: the WHEN only
; tests the goal + whereabouts; precedence is the utility competition (b2).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

; (a) DESIRE - window-start craving appraisal. Risk = vulnerability x environment /
; protection (low industriousness/politeness = disinhibition, volatility = reactive,
; withdrawal = self-medication, enthusiasm = social; low wealth = stress; piety +
; belonging = protection). Already-dependent NPCs are excluded (relapse casts them).
(hsim-npc-behaviour crave_drink
  (long-term-think)
  (rng-stream behaviour)
  (roles
    (role @self (template grown)))
  (when (and (not (= (target {@self craving}) [k alcohol]))
             (chance
               (* 0.014                                                  ; base daily rate
                  (+ 0.55 (* 0.90 (- 1.0 (attr @self industriousness)))) ; low industriousness
                  (+ 0.65 (* 0.70 (- 1.0 (attr @self politeness))))      ; low politeness
                  (+ 0.70 (* 0.60 (attr @self volatility)))              ; reactive drinking
                  (+ 0.70 (* 0.60 (attr @self enthusiasm)))              ; social drinking
                  (+ 0.70 (* 0.60 (attr @self withdrawal)))              ; self-medication
                  (- 1.5 (target {@self wealth}))                       ; low wealth -> stress
                  (- 1.5 (target {@self piety}))                        ; low piety -> less protection
                  (- 1.5 (target {@self belonging}))))))                ; low belonging -> less protection
  (effects
    (begin-goal {@self drink})))

; (b) APPROACH - hold the goal, nowhere to drink: set out for a pub. drink-venue
; picks a same-town pub; k_fail (no pub reachable) means the rule does not fire and
; the goal simply waits.
