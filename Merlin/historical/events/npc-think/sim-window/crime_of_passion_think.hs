; ----------------------------------------------------------------------------
; crime_of_passion.hs - instrumental homicide genesis: obsession (one-sided crave).
;
; Sibling of covet_inheritance.hs / ambition.hs / predation.hs. An actor consumed
; by one-sided attraction (a `crave` stance toward a beloved) turns murderous:
; kill the RIVAL for the beloved's affections (the beloved's spouse / lover - an
; innocent obstacle, the instrumental case), or, when no rival is known, the
; spurned beloved themselves ("if I can't have you ...", the passion case).
;
; PURE .hs (no C++ generator). This is the FALLBACK branch of the old
; (generative-obsession) arbiter, now its own event (the arbiter's betrayal /
; clear-marriage / rid-of-spouse branches are betrayal_kill.hs / clear_marriage.hs
; / rid_of_spouse.hs). The selection that run_generative_obsession dispatched is
; expressed here:
;   - (role ?beloved ... (believes {@self crave ?beloved})
;     (select (policy first-match))) binds ONE craved beloved, so a multi-crave
;     obsessive strikes a single victim per tick;
;   - (when ...) is the jealous-rage pre-gate (volatility + psychopathy, scaled by
;     disinhibition, at the 0.02 obsession base rate) PLUS (not (knows-affair))
;     - crave is the fallback, so a known betrayal routes to betrayal_kill.hs instead
;     (the old arbiter's betrayed -> A, else crave precedence);
;   - (crave-rival ?beloved) resolves the victim - the beloved's spouse / lover read
;     in the ACTOR'S own mind, else the beloved (the one irreducible computation,
;     exposed as a verb);
;   - (effects ...) mints {actor goal {actor kill <victim>}} /cause-pinned to the
;     crave belief, so the rap-sheet reads "kill <victim> <- {@self crave <beloved>}".
; attempt_harm then consumes the goal and executes a kill method as usual.
;
; Kept rare by design (the 0.02 base rate + the rage gate). To A/B, rename / remove
; this file (runtime-loaded; no rebuild).
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think crime_of_passion
  (sim-window-think)
  (rng-stream perpetration)

  (role @self )
  ; The craved beloved. The crave stance is the object-cache filter;
  ; (policy first-match) binds ONE, so a multi-crave actor strikes a
  ; single victim per tick (parity with the old first-viable walk).
  (role ?beloved (any_human ?beloved)
    (believes {@self crave ?beloved})
    (select (policy first-match)))

  ; Jealous-rage pre-gate + the fallback guard. rage = mean(volatility, psychopathy);
  ; propensity = (1 - inhibition) * rage; fire at 0.02 * propensity. (knows-affair)
  ; keeps crave the FALLBACK: a discovered betrayal routes to betrayal_kill.hs.
  ; The jealous-rage tail released by disinhibition, at the 0.02 base rate
  ; (score_macros.hs); crave is the FALLBACK, so a known affair routes to
  ; betrayal_kill.hs instead.
  (when (and (not (knows-affair))
             (chance (* (crime-scale) 0.02
                        (dark-propensity @self (rage-disposition @self))))))

  ; crave-rival resolves the rival for the beloved (read in @self's own mind), else
  ; the beloved. /cause pins the crave belief - the obsessive signature.
  (cont-fire-effects
    (debug-print "TRACE_PASSION_FIRES @self beloved=?beloved")
    (bind (crave-rival ?beloved) ?victim)
    (if (not (believes {?victim condition [k dead]}))
        (do (debug-print "TRACE_KILLGOAL passion @self -> ?victim")
            (begin-goal {@self kill ?victim} /cause {@self crave ?beloved})))))
