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
;   - (role ?benefactor ... (prefer ...)) binds the single WEALTHIEST co-heir
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

(include "../../definitions/roles.hs")

(hsim-npc-behaviour covet_inheritance
  (long-term-think)
  (rng-stream perpetration)

  (roles
    (role @self (template any_human))
    ; The wealthiest co-heir benefactor the actor KNOWS. The kin edge is the
    ; object-cache filter (Shape-1 {@self <label> ?cand}); (prefer) ranks the
    ; cached set by believed wealth and binds the single richest. The wealth
    ; floor is enforced in (when) on the winner.
    (role ?benefactor (template any_human)
      (believes {@self mother|father|parent|spouse|sibling ?benefactor})
      (prefer (target {?benefactor wealth}))))

  ; Disposition pre-gate + wealth floor. greed = mean(machiavellianism, psychopathy);
  ; propensity = (1 - inhibition) * greed; fire at k_covet_base_rate * propensity.
  (when (and (>= (target {?benefactor wealth}) 0.5)
             (chance (* (crime-scale) 0.02
                        (* (- 1 (target {@self inhibition}))
                           (* 0.5 (+ (attr @self machiavellianism)
                                     (attr @self psychopathy))))))))

  ; Mint the kill goal toward the resolved victim. heir-apparent reads the
  ; benefactor's kin graph (the one irreducible computation, exposed as a verb).
  ; /cause pins @self's belief in the benefactor's wealth - the appetitive motive -
  ; so the rap sheet reads "kill <victim> <- {<benefactor> wealth ..}".
  (effects
    (bind (heir-apparent ?benefactor) ?heir)
    (if (= ?heir @self)
        (begin-goal {@self kill ?benefactor} /cause {?benefactor wealth})
        (if (alive ?heir)
            (begin-goal {@self kill ?heir} /cause {?benefactor wealth})))))
