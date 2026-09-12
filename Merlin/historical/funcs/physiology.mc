; ----------------------------------------------------------------------------
; run_physiology (define-func) - the bodily-drive advance, authored as content.
;
; Invoked by the engine (call_hs_func, cached index) at EACH act completion, on
; the completing actor, with ?duration = the act's elapsed minutes and ?recovers = 1
; iff it was a SLEEP act (else 0). A plain callable func - no act-belief, no
; deliberation; C++ only supplies the two per-completion scalars.
;
; The drives (the ONE seam where the body advances):
;  - ADRENALINE decays toward 0 over ~1h of non-fight acts (the fight / flee /
;    scream acts pump it to 1 content-side). It MASKS the felt drives: the raw
;    fatigue / hunger DEBTS keep accruing, but sleepiness / appetite = debt*mask,
;    so a combatant reads calm until the surge fades - then the debt lands at
;    once (the post-fight crash).
;  - FATIGUE: a SLEEP act recovers it, any other act accrues waking fatigue. The
;    masked value (sleepiness) drives the sleep-pull utility.
;  - HUNGER: every act accrues it, sleep included (you wake hungry). Meal acts
;    reduce it content-side. The masked value (appetite) gates the meal lane.
;
; ATTRS ONLY. The engine's update_physiology calls this and then mirrors the actor's
; attrs into self-beliefs, so every drive this func moves arrives on the belief plane
; by the one route every other attr takes. A belief minted here would be a second,
; divergent account of the same number.
; ----------------------------------------------------------------------------

(include "../macros/physiology-macros.mc")

(define-func run_physiology (?duration ?recovers)
  (/ ?duration 60): ?hours

  (clamp (- (attr @self adrenaline) (* ?hours (adrenaline_decay_per_hour)))
         0 (adrenaline_max)): ?adren
  (- 1 ?adren): ?mask

  (- (* (* ?hours (fatigue_accrue_per_hour)) (- 1 ?recovers))
     (* (* ?hours (fatigue_recover_per_hour)) ?recovers)): ?df
  (clamp (+ (attr @self fatigue) ?df) 0 (fatigue_max)): ?fatigue
  (* ?fatigue ?mask): ?sleepiness

  (clamp (+ (attr @self hunger) (* ?hours (hunger_accrue_per_hour)))
         0 (hunger_max)): ?hunger
  (* ?hunger ?mask): ?appetite

  (if (has-attr @self fatigue)
    (then
      (set-attr @self adrenaline ?adren)

      (set-attr @self fatigue ?fatigue)
      (set-attr @self sleepiness ?sleepiness)

      (set-attr @self hunger ?hunger)
      (set-attr @self appetite ?appetite))))
