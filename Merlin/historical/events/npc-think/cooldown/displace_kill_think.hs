; ----------------------------------------------------------------------------
; displace_kill (npc-think). Displaced rage: a reactive KILL whose wrongdoer-focus
; is UNREACHABLE - dead, or far out-ranking the actor in standing - is discharged
; onto a weaker innocent in the actor's own social orbit, re-routed to a beating
; (hurt), never a premeditated bystander kill. The disliked are preferentially -
; never exclusively - hit; a floor lets the rage land on any known acquaintance.
;
; SCOPE. Only the reactive-deliberation kill displaces: its goal carries a
; {@self pressure ..} /caused_by (the grievance), which (caused-by ?kgoal ...)
; returns and every appetitive / instrumental kill lacks (predation pins {@self
; fixation}, covet {?b wealth}, ambition {@self job.org}, passion {@self crave ..},
; betrayal {@self emotion ..}, rid_of_spouse {@self detest ..}). The window is
; pre-fight: (no-goal {@self fight ?focus}) closes it once the stalk begins.
;
; Per-mind reads, no telepathy: standing is @self's OWN belief ({?x prestige}, absent
; -> readily dominated), and the dislike weight is the warmth band beliefs @self
; personally holds ({@self dislike/detest}).
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think displace_kill
  (cooldown 1 m)
  (rng-stream incidents)

  ; ?focus = the unreachable wrongdoer, bound off the standing kill goal;
  ; ?kgoal = THIS activation's goal belief (the fan-out identity), so the
  ; pressure read below chases the right goal's /caused_by.
  (goal {@self kill ?focus}:?kgoal)
  (role @self )

  ; The substitute: any alive acquaintance, stance-weighted so the disliked land the
  ; blow most. floor 0.10 lets displaced rage hit anyone known; a warmth band of
  ; dislike adds one bonus rung, detest two. A role binds before (when), so an actor
  ; with no acquaintance no-fires.
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
             (is-belief (caused-by ?kgoal {@self pressure ?}))
             (or (believes {?focus condition [k dead]})
                 (>= (- (target-or ?focus prestige 0) (target-or @self prestige 0)) 0.25))
             (chance (* 0.5 (disinhibition) 0.5
                        (+ (attr @self volatility) (callousness @self))))))

  ; Re-route: drop the kill, discharge the grievance as a beating on the substitute,
  ; carrying the ORIGINAL pressure as /caused_by so terminal-harm-non-lethal discharges
  ; the right grievance (else the actor re-deliberates it next month).
  (effects
    (caused-by ?kgoal {@self pressure ?}): ?pressure
    (end-goal {@self kill ?focus})
    (begin-goal {@self hurt ?sub} /caused_by ?pressure)))
