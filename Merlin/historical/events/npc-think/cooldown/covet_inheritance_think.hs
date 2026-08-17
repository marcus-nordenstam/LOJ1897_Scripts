; ----------------------------------------------------------------------------
; covet_inheritance.hs - instrumental (appetitive) homicide genesis.
;
; The appetitive counterpart to the reactive pressure-deliberation path
; (deliberate.hs). Where deliberation turns a GRIEVANCE into a goal against the
; wrongdoer, this event turns a WANT (a wealthier relative's fortune) into a
; goal against an INNOCENT obstacle - the rich kin. The victim is selected for
; what removing them achieves (the inheritance), not for anything they did.
;
; PURE .hs (no C++ generator). The selection that the old (generative-covet)
; flag dispatched to run_generative_covet is expressed here with the engine's
; scored select-one primitive:
;   - (role ?benefactor ... (select (score ...))) binds the single WEALTHIEST co-heir
;     benefactor the actor knows (parent / spouse / sibling - the pick_heir
;     co-heir set, NOT cousins / grandparents),
;   - (when ...) is the disposition pre-gate (callous-acquisitive: machiavellianism
;     + psychopathy, scaled by disinhibition, at the covet base rate) plus the
;     wealth floor on the chosen benefactor,
;   - (effects ...) mints {actor goal {actor kill <victim>}}, where the victim is
;     the benefactor's heir-apparent: if the ACTOR is that heir, the benefactor is
;     the obstacle (impatient heir); otherwise the front-running heir is (clear the
;     succession). (goal) is alive-gated, so a dead / absent heir mints nothing.
; attempt_harm then consumes the goal and executes a kill method as usual.
;
; Kept rare by design (the 0.02 base rate below). To A/B the motive, rename /
; remove this file (runtime-loaded; no rebuild).
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think covet_inheritance
  (cooldown 1 m)
  (rng-stream perpetration)

  (role @self )
  ; The wealthiest co-heir benefactor the actor KNOWS. The kin edge is the
  ; object-cache filter (Shape-1 {@self <label> ?cand}); (select (score ...)) ranks the
  ; cached set by believed wealth and binds the single richest. The wealth
  ; floor is enforced in (when) on the winner.
  (role ?benefactor (any_human ?benefactor)
    {@self mother|father|parent|spouse|sibling ?benefactor}
    (select (score (any {?benefactor wealth}).target)))
  ; The benefactor's HEIR, role-cast via the object-cache JOIN: the cross-role filter
  ; {?heir <kin> ?benefactor} makes ?heir's cache depend on ?benefactor's - the engine
  ; materializes, per benefactor, the heirs the actor KNOWS (a candidate's own kin
  ; belief toward that benefactor: a child's parent IS the benefactor, a spouse's
  ; spouse IS, a sibling's sibling IS - the pick_heir co-heir set). old_human gates on
  ; the PERCEIVED age band (marriageable-age, minted on sight even for strangers) - a
  ; grown co-heir who stands to inherit. No exact-age read: birth_date is a
  ; friends-and-closer disclosure, and without parish records the actor cannot rank
  ; co-heirs by exact age, so first-match binds one perceived co-heir obstacle rather
  ; than the strict eldest. No omniscient (heir-apparent ...) kin-graph read.
  (role ?heir (old_human ?heir)
    {?heir mother|father|parent|spouse|sibling ?benefactor}
    (select (policy first-match)))

  ; Disposition pre-gate + wealth floor. greed = mean(machiavellianism, psychopathy);
  ; propensity = (1 - inhibition) * greed; fire at k_covet_base_rate * propensity.
  (when (and (>= (any {?benefactor wealth}).target 0.5)
             (chance (* (crime-scale) 0.02
                        (* (- 1 (inhibition))
                           (* 0.5 (+ (attr @self machiavellianism)
                                     (attr @self psychopathy))))))))

  ; Mint the kill goal toward the resolved victim. heir-apparent reads the
  ; benefactor's kin graph (the one irreducible computation, exposed as a verb).
  ; /caused_by pins @self's belief in the benefactor's wealth - the appetitive motive -
  ; so the rap sheet reads "kill <victim> <- {<benefactor> wealth ..}".
  (utility want)
  (effects
    (any {?benefactor wealth ?}).target: ?benefactor_wealth
    (begin-belief {?benefactor wealth ?benefactor_wealth}): ?wealth_bond
    (if (= ?heir @self)
        (then (begin-goal {@self kill ?benefactor} /caused_by ?wealth_bond))
        (else (begin-goal {@self kill ?heir} /caused_by ?wealth_bond)))))
