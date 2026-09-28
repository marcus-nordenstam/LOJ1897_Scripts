; ----------------------------------------------------------------------------
; crime-of-passion.mc - instrumental homicide genesis: obsession (one-sided crave).
;
; Sibling of covet-inheritance.mc / ambition.mc / predation.mc. An actor consumed
; by one-sided attraction (a `crave` stance toward a beloved) turns murderous:
; kill the RIVAL for the beloved's affections (the beloved's spouse / lover - an
; innocent obstacle, the instrumental case), or, when no rival is known, the
; spurned beloved themselves ("if I can't have you ...", the passion case).
;
; PURE .mc (no C++ generator). This is the FALLBACK branch of the old
; (generative-obsession) arbiter, now its own rule (the arbiter's betrayal /
; clear-marriage / rid-of-spouse branches are betrayal-kill.mc / clear_marriage.mc
; / rid-of-spouse.mc). The selection that run_generative_obsession dispatched is
; expressed here:
;   - (role ?beloved ... (any {@self crave ?beloved})
;     (select (policy first-match))) binds ONE craved beloved, so a multi-crave
;     obsessive strikes a single victim per tick;
;   - (when ...) is the jealous-rage pre-gate (volatility + psychopathy, scaled by
;     disinhibition, at the 0.02 obsession base rate) PLUS (not (knows-affair))
;     - crave is the fallback, so a known betrayal routes to betrayal-kill.mc instead
;     (the old arbiter's betrayed -> A, else crave precedence);
;   - (crave-rival ?beloved) resolves the victim - the beloved's spouse / lover read
;     in the ACTOR'S own mind, else the beloved (the one irreducible computation,
;     exposed as a verb);
;   - (effects ...) MAINTAIN-proposes the {@self kill <victim>} task /caused_by-pinned
;     to the crave belief; the kill task picks the method and drives the blow, and the
;     drive fades when the crave does.
;
; Kept rare by design (the 0.02 base rate + the rage gate). To A/B, rename / remove
; this file (runtime-loaded; no rebuild).
; ----------------------------------------------------------------------------



(think crime-of-passion
  (cooldown 1 m try-once)
  (rng-stream perpetration)

  (role @self {@self volatility ?volatility}
              {@self psychopathy ?psychopathy}
              {@self inhibition ?inhibition} 
    ; The craved beloved - the durable REASON; capture the crave belief as the
    ; /caused_by anchor (read, never re-minted, so the drive fades when the crave does).
    ; (policy first-match) binds ONE, so a multi-crave actor pursues a single victim.
    (role ?beloved {?beloved isa [k human], condition [k alive]}
      {@self crave ?beloved}:?crave_bond
      (select (policy first-match))

      ; crave-rival resolves the rival for the beloved (read in @self's own mind), else
      ; the beloved themselves.
      (bind (cond
              (case (any {?beloved spouse ?rival-spouse}) ?rival-spouse)
              (case (any {?beloved lover ?rival-lover}) ?rival-lover)
              (else ?beloved)) ?victim)

      ; MAINTAIN the kill while the crave holds and the victim lives. The jealous-rage
      ; tip fires ONCE (chance = 0.02 * (1-inhibition) * mean(volatility,psychopathy)),
      ; then the RUNNING kill act latches it so it is not re-rolled; the
      ; drive drops when the crave fades or the victim dies. (knows-affair) keeps crave the
      ; FALLBACK - a discovered betrayal routes to betrayal-kill.mc.
      (when (and (not (knows-affair))
                 -{?victim condition [k dead]}
                 (or {@self kill ?victim}
                     (chance (* (crime-scale) 0.02
                                (* (- 1.0 ?inhibition) (* 0.5 (+ ?volatility ?psychopathy))))))))
      (utility want)
      (effects
        (maintain-proposal {@self kill ?victim /caused_by ?crave_bond})))))
