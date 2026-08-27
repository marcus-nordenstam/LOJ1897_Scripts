; ----------------------------------------------------------------------------
; combat_actions.hs - the dumb, general VIOLENT ACTIONS the killing tasks and the
; fight task propose. Each is ONE blow (duration 1):
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
; The shared per-blow physics (adrenaline + hit roll + fatal/knockout/miss dispatch)
; lives in combat_macros.hs. There is NO C++ for any of this.
; ----------------------------------------------------------------------------

(include "../../macros/combat_macros.hs")

; CHOKE - the strangle task's bare-handed lethal blow. Solid grip kills; a slipping
; grip may still throttle the life out over the exchange (the succumb roll). Ledgered
; as the `strangle` method of a `kill`.
(npc-action {@self CHOKE ?foe}
  (obs) (theme violent_to) (construed_act harm_act) (contradicts safety) (duration 1) ;(track-skill-level [k garrotting]) 
  (effects
    (strike-body
      (do (yield-evidence @self ?foe head ligature_mark) (kill-blow ?foe strangle))
      (do (yield-evidence @self ?foe head bruise)
          (if (chance (blow_succumb_prob)) (then (kill-blow ?foe strangle)))))
    (set-outcome {@self CHOKE ?foe} succ)))

; TRIGGER_FIREARM - the shoot task's firearm blow. A clean shot kills; a winging shot
; may still prove mortal (the succumb roll). Ledgered as the `shoot` method of a `kill`.
(npc-action {@self TRIGGER_FIREARM ?foe}
  (obs) (theme violent_to) (construed_act harm_act) (contradicts safety) (duration 1) ;(track-skill-level [k marksmanship]) 
  (effects
    (strike-body
      (do (yield-evidence @self ?foe head puncture_wound) (kill-blow ?foe shoot))
      (do (yield-evidence @self ?foe right_hand puncture_wound)
          (if (chance (blow_succumb_prob)) (then (kill-blow ?foe shoot)))))
    (set-outcome {@self TRIGGER_FIREARM ?foe} succ)))

; PUNCH - the NON-LETHAL bare-fists blow: a solid hit KNOCKS OUT (writes awareness
; unconscious - ends the foe's turn in the melee), a graze only bruises, a whiff posts
; the clumsiness marker. NEVER fatal, no succumb roll. Both the fight-back (a victim
; repelling their attacker) and the hurt beating use it.
(npc-action {@self PUNCH ?foe}
  (obs) (theme violent_to) (construed_act harm_act) (contradicts safety) (duration 1) ; (track-skill-level [k martial])
  (effects
    (strike-body
      (do (yield-evidence @self ?foe head bruise) (set-attr ?foe awareness unconscious))
      (yield-evidence @self ?foe torso bruise))
    (set-outcome {@self PUNCH ?foe} succ)))
