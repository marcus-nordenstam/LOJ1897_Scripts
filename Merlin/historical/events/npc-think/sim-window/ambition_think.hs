; ----------------------------------------------------------------------------
; ambition.hs - instrumental homicide genesis: ambition (npc-think).
;
; Sibling of covet_inheritance.hs. A cold, ambitious actor who is the CLEAR
; HEIR-APPARENT of their organisation's leadership post - the most-senior employee
; below the org_head - murders the incumbent to take the seat. The victim is an
; OBSTACLE (an innocent who holds the post), not a wrongdoer.
;
; PURE .hs (no C++ generator). The selection that the old (generative-ambition)
; flag dispatched to run_generative_ambition is expressed here:
;   - (when ...) is the disposition pre-gate (ambition = mean(machiavellianism,
;     narcissism), scaled by disinhibition, at the 0.03 base rate) plus the adult floor,
;   - (ambition-target @self) resolves the obstacle - the org_head the actor is the
;     clear deputy behind (@fail otherwise, so non-deputies no-fire). The one
;     irreducible org-hierarchy computation, exposed as a verb (sibling of
;     (heir-apparent ...)),
;   - (effects ...) mints {actor goal {actor kill <head>}}, /cause-pinned to the
;     actor's `employer` belief (their stake in the org), so the rap sheet reads
;     "kill <head> <- {@self employer <org>}".
; attempt_harm then consumes the goal and executes a kill method as usual. The
; payoff is real: promote_on_vacancy (propagate_death) lifts the actor into the
; vacated org_head rank, so the murder pays off.
;
; Kept rare by design (the 0.03 base rate + the clear-deputy requirement, so only a
; handful of NPCs qualify at any time). To A/B the motive, rename / remove this file
; (runtime-loaded; no rebuild).
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think ambition
  (sim-window-think)
  (rng-stream perpetration)

  (role @self (any_human @self)
              (adult @self))

  ; Disposition pre-gate + adult floor. ambition = mean(machiavellianism, narcissism);
  ; propensity = (1 - inhibition) * ambition; fire at 0.03 * propensity.
  (when (chance (* (crime-scale) 0.03
                   (* (- 1 (classifier-value inhibition))
                      (* 0.5 (+ (attr @self machiavellianism)
                                (attr @self narcissism)))))))

  ; Mint the kill goal toward the resolved obstacle. ambition-target reads the org
  ; hierarchy (the one irreducible computation, exposed as a verb). /cause pins
  ; @self's employer belief - the instrumental stake - so the rap sheet reads
  ; "kill <head> <- {@self employer <org>}".
  (cont-fire-effects
    (bind (ambition-target @self) ?victim)
    (if (not (believes {?victim condition [k dead]}))
        (begin-goal {@self kill ?victim} /cause {@self employer}))))
