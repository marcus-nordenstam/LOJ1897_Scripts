; ----------------------------------------------------------------------------
; The DRINKING lane (B4 pressure model). ONE think:
;   crave_drink (npc-think): drink PRESSURE = days-since-last-drink ramp x a
;     drinking PROPENSITY (low industriousness = disinhibition, high withdrawal =
;     self-medication), capped as a LEISURE act. It rises until the NPC drinks
;     (which resets it), so a susceptible man returns to drink regularly while a
;     temperate one's utility never clears a routine act. can-drink (a pub OR his
;     own home) -> the drink act-goal; otherwise -> a `go` sub-act-goal to a pub.
;   drink_act (npc-act, drink.hs): the durative drink - bumps intoxication, rolls
;     the slide into dependence, ends the act. The {@self drink} act-belief IS the
;     episodic memory days-since-last reads. No aim, no end-goal.
;
; Already-dependent NPCs are excluded here (relapse.hs casts them - a second
; additive drink source, like rehabilitation is for worship).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-think crave_drink
  (short-term-think)
  (roles
    (role @self (template grown)))
  ; Not already dependent; a drink ~due (perf: most passes skip).
  (when (and (not (= (target {@self craving}) [k alcohol]))
             (>= (days-since-last @self drink) 3)))
  ; propensity (disinhibition + self-medication, capped) x days-since ramp; the
  ; leisure ceiling keeps drinking in the day's gaps, never over work / sleep, and
  ; the propensity multiplier keeps a temperate man's utility below every routine
  ; act (he effectively never drinks to excess).
  (utility (* (min (+ 0.35
                      (* 0.9 (- 1 (attr @self industriousness)))
                      (* 0.8 (attr @self withdrawal))) 1.5)
              (min (* (days-since-last @self drink) 2) 30)))
  (effects
    (if (can-drink @self)
        (begin-goal {@self drink})
        (do (bind (venue [k building pub]) ?go_dest)
            (if (is-entity ?go_dest) (begin-goal {@self go ?go_dest}))))))
