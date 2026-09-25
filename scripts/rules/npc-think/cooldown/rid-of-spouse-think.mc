; ----------------------------------------------------------------------------
; rid_of_spouse.mc - instrumental homicide genesis: rid of a hated/abusive spouse.
;
; A cold instrumental branch of the affair-homicide family (siblings:
; crime_of_passion.mc, betrayal_kill.mc, clear_marriage.mc). An actor kills their
; spouse out of standing HATRED or ABUSE - to live in peace - independent of any
; lover, amplified by the spouse's ESTATE (the widow's portion pays for the
; childless) and by an UNMARRIAGEABLE lover waiting (the affair carries on into
; widowhood). A festering standing state, not a fresh grievance, so it carries its
; OWN misery gate (no rage gate).
;
; PURE .mc. The selection that run_generative_rid_of_spouse dispatched is spelled
; out here over composable ops:
;   - (role ?spouse ...) binds the actor's spouse;
;   - (when ...) is the misery gate (deep negative warmth - the detest band <= -2 -
;     OR the spouse's assault record against the actor) plus the propensity roll
;     (misery * (0.5+psychopathy) * disinhibition * (1-compassion) *
;     (1 + spouse-wealth) * unmarriageable-lover-mult, at the 0.02 base rate);
;   - (effects ...) MAINTAIN-proposes {@self kill <spouse>} /caused_by-pinned to the
;     held detest / dislike belief, else the spouse-wealth belief - all READ, never
;     re-minted, so the drive fades as the reason does ("kill <spouse> <- {@self detest
;     <spouse>}" or "... <- {<spouse> wealth 0.8}"). The (when) drops the drive when the
;     spouse dies and latches the one-time impulse so it is not re-rolled.
; attempt_harm then consumes the proposal and executes a method as usual.
;
; Kept rare by design (the misery gate + base rate). To A/B, rename / remove this
; file (runtime-loaded; no rebuild).
; ----------------------------------------------------------------------------


(npc-think rid_of_spouse
  (cooldown 1 m try-once)
  (rng-stream perpetration)

  (role @self 
              {@self age-band [k young-adult|middle-aged|mature|elderly]}
    (role ?spouse {?spouse isa [k human], condition [k alive]} {@self spouse ?spouse} (select (policy first-match))

      ; The REASON: the held detest belief, else dislike, else the spouse-wealth belief.
      ; Read as the /caused_by anchor, never re-minted, so the drive fades as the reason
      ; does. The attitude / wealth beliefs are minted elsewhere by the appraisal chains.
      (cond
        (case {@self detest ?spouse}  (any {@self detest ?spouse}))
        (case {@self dislike ?spouse} (any {@self dislike ?spouse}))
        (else                         (any {?spouse wealth}))): ?spouse_bond

      ; Misery gate (deep hatred OR abuse) + propensity. misery counts the two:
      ; hated = warmth band toward the spouse <= -2 (the detest band); abused = the
      ; spouse holds an assault record against the actor. propensity = misery *
      ; (0.5 + psychopathy) * (1 - inhibition) * (1 - compassion) * (1 + spouse-wealth).
      (when (and (or (detests ?spouse)
                     {?spouse (theme-labels violent-to) @self /ever})
                 -{?spouse condition [k dead]}
                 (or {@self kill ?spouse}
                     (chance
                       (* (crime-scale) 0.02
                          (* (+ (if (detests ?spouse) (then 1) (else 0))
                                (if {?spouse (theme-labels violent-to) @self /ever} (then 1) (else 0)))
                             (* (+ 0.5 (target-or @self psychopathy 0.0))
                                (* (disinhibition)
                                   (* (callousness @self)
                                      (+ 1 (any {?spouse wealth}).target))))))))))

      (utility want)
      (effects
        (maintain-proposal {@self kill ?spouse /caused_by ?spouse_bond})))))
