; ----------------------------------------------------------------------------
; combat_actions.hs - the dumb, general VIOLENT ACTION the killing tasks and the
; fight task propose. STRIKE is ONE blow (duration 1):
;   (obs)                       - witnesses SEE the blow (per-motor perception),
;                                 so bystanders internalize + appraise it;
;   (theme violent_to)          - the ontology theme (theme violent_to) that both
;                                 the runtime-blame gate (appraisal.cc) and the
;                                 defender's (theme-labels violent_to) match read;
;   (construed_act harm_act) (contradicts safety) - harm is static; BLAME is
;                                 runtime: appraisal SUPPRESSES wrong_act for a blow
;                                 that traces (/caused_by) to a violent act on its
;                                 own actor (self-defence), so the aggressor is blamed
;                                 and the defender who strikes back is not.
; The blow rolls ONCE (adrenaline + @self strength/dexterity - intoxication; all own-attr
; reads = blessed act physics): a solid HIT, a GRAZE, or a clean MISS (posts the whiff
; marker, publicly observable clumsiness the flee roll reads). The /aux method - strangle /
; shoot / punch, chosen by the driving task - selects only the forensic wound signature
; (site + mark) and the lethality: strangle and shoot KILL (a landed blow outright, a graze
; may still succumb - blow_succumb_prob via kill-blow), punch is a NON-LETHAL knockout (a
; landed blow writes awareness unconscious, ending the foe's turn; a graze only bruises).
; The two fidelity terms the C++ blow had drop out deliberately (the defender's active dodge
; - the fight's two-sidedness carries it - and the competence-band bonus, a think-side
; hand-in). There is NO C++ for any of this.
; ----------------------------------------------------------------------------

(include "../../macros/combat-macros.mc")

(npc-action {@self STRIKE ?foe ?method}
  (track-skill-level [k martial])
  (obs) (theme violent_to) (construed_act harm_act) (contradicts safety) (duration 1)
  (effects
    (set-attr @self adrenaline 1)
    (clamp (+ 0.45
              (* 0.30 (- (attr @self strength) 0.5))
              (* 0.40 (- (attr @self dexterity) 0.5))
              (* -1.2 (attr @self intoxication)))
           0.02 0.98): ?p
    (rng-unit): ?u
    (if (< ?u ?p)
      (then
        (if (= ?method punch)
          (then (yield-evidence @self ?foe head bruise) (set-attr ?foe awareness unconscious))
        (else (if (= ?method shoot)
          (then (yield-evidence @self ?foe head puncture_wound) (kill-blow ?foe shoot))
        (else (yield-evidence @self ?foe head ligature_mark) (kill-blow ?foe strangle))))))
      (else (if (< ?u (+ ?p 0.30))
        (then
          (if (= ?method punch)
            (then (yield-evidence @self ?foe torso bruise))
          (else (if (= ?method shoot)
            (then (yield-evidence @self ?foe right_hand puncture_wound)
                  (if (chance (blow_succumb_prob)) (then (kill-blow ?foe shoot))))
          (else (yield-evidence @self ?foe head bruise)
                (if (chance (blow_succumb_prob)) (then (kill-blow ?foe strangle))))))))
        (else (pub-bb-post @self whiffed (whiff_ttl_cycles))))))
    (set-outcome {@self STRIKE ?foe ?method} /succ)))
