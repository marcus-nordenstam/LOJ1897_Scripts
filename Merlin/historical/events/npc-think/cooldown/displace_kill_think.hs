; ----------------------------------------------------------------------------
; displace_kill (npc-think). Displaced rage: a reactive KILL whose wrongdoer-focus
; is UNREACHABLE - dead, or far out-ranking the actor in standing (you cannot strike
; the powerful) - is discharged onto a weaker innocent in the actor's own social
; orbit, re-routed to a beating (hurt), never a premeditated bystander kill.
;
; The old C++ (displace-victim) verb, event-ized. It ran INSIDE resolve-deliberation
; the moment the reactive kill goal was minted; a stance-weighted RESERVOIR SAMPLE is
; a role-cast + (select (policy roulette)), so the selection is now an event header,
; not an effect call. This is the sibling of bonded_incident_insult (the same
; displaced-anger shape): the disliked are preferentially - never exclusively - hit,
; a floor lets the rage land on any acquaintance.
;
; SCOPE. Only the reactive-deliberation kill displaces: its goal carries a
; {@self pressure ..} /cause (the grievance), which (driving-pressure-of-goal ...)
; returns and every APPETITIVE / instrumental kill lacks (predation pins {@self
; fixation}, covet {?b wealth}, ambition {@self job.org}, passion {@self crave ..},
; betrayal {@self emotion ..}, rid_of_spouse {@self detest ..}) - so those never
; re-route. The window is pre-fight: once attempt_kill has minted the fight goal the
; stalk has begun and the decision has passed ((no-goal {@self fight ?focus})).
;
; HONEST READS (per-mind, no telepathy). The C++ read every candidate's and the
; focus's true prestige by ENTERING their mind. Here standing is @self's OWN belief
; ({?x prestige}, absent -> readily dominated / not out-ranking), and the dislike
; weight is the warmth band beliefs @self personally holds ({@self dislike/detest}) -
; the reservoir sampler's substrate. Standing-about-others rarely propagates yet, so
; the too-powerful arm and any weakness narrowing stay latent until it does (the
; per-mind believed-standing refinement is deferred to the signals program); the
; live trigger is the dead-focus grievance, and the pool is the known orbit - exactly
; bonded_incident_insult's pool.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think displace_kill
  (cooldown 1 m)
  (rng-stream incidents)

  ; ?focus = the unreachable wrongdoer, bound off the standing kill goal.
  (goal {@self kill ?focus})
  (role @self )

  ; The substitute: any alive acquaintance, stance-weighted so the disliked land the
  ; blow most. floor 0.10 = displaced rage can hit anyone known; a warmth band of
  ; dislike adds one bonus rung, detest two (mirrors the C++ 0.10 + 0.30*(-warmth)).
  ; The (select roulette) IS the reservoir sample. A role binds before (when), so an
  ; actor with no acquaintance no-fires (matches the C++ empty-pool -> no displacement).
  (role ?sub (any_human ?sub)
             (personally-knows @self ?sub)
             (select (score (+ 0.10
                               (* 0.30 (+ (believes {@self dislike ?sub})
                                          (* 2 (believes {@self detest ?sub}))))))
                     (policy roulette)))

  ; Trigger: a SPECIFIC wrongdoer the actor cannot strike (believed dead, or out-
  ; ranking the actor by a standing band), the kill still pre-fight, and it must be
  ; the reactive-grievance kill (a real driving pressure). Then the propensity roll -
  ; a disinhibited, volatile, callous impulse, base-rate 0.5 keeping it a tail
  ; (chance = 0.5 * disinhibition * 0.5 * (volatility + callousness)).
  (when (and (is-entity ?focus)
             (no-goal {@self fight ?focus})
             (is-belief (driving-pressure-of-goal (goal-belief kill)))
             (or (believes {?focus condition [k dead]})
                 (>= (- (target-or ?focus prestige 0) (target-or @self prestige 0)) 0.25))
             (chance (* 0.5 (disinhibition) 0.5
                        (+ (attr @self volatility) (callousness @self))))))

  ; Re-route: drop the kill, discharge the grievance as a beating on the substitute,
  ; carrying the ORIGINAL pressure as /cause so terminal-harm-non-lethal discharges
  ; the right grievance (else the actor re-deliberates it next month).
  (effects
    (bind (driving-pressure-of-goal (goal-belief kill)) ?pressure)
    (end-goal {@self kill ?focus})
    (begin-goal {@self hurt ?sub} /cause ?pressure)))
