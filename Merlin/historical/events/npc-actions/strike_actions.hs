; ----------------------------------------------------------------------------
; strike_actions.hs - the ATTACK-ACTION FAMILY (batch-3 Lane 1, ruling 7). One
; primitive (obs) npc-action per attack class; the fight TASK selects which to
; propose from the weapon in hand. Each action is ONE blow (duration 1), carrying
; its class's wound literals; the shared roll + fatal/knockout/miss dispatch lives
; in combat_macros.hs. The blows are morally NEUTRAL - blame lives on the `assault`
; task, so a defender's blows carry no wrong_act. (obs) makes each blow witnessed as
; {attacker <verb> victim} - testimony with texture, ended when the blow stops.
; ----------------------------------------------------------------------------

(include "../../macros/combat_macros.hs")

; STRIKE - bare-handed pummelling (kill intent). pugilism.
(npc-action {@self STRIKE ?foe}
  (obs)
  (theme violent_to)
  (duration 1)
  (effects
    (strike-body
      (do (yield-evidence @self ?foe head blunt_wound) (kill-blow ?foe strike))
      (do (yield-evidence @self ?foe torso bruise)
          (if (chance (blow_succumb_prob)) (then (kill-blow ?foe strike)))))
    (set-outcome {@self STRIKE ?foe} succ)))

; STAB - a pointed blade to the torso (kill intent). knife_fighting.
(npc-action {@self STAB ?foe}
  (obs)
  (theme violent_to)
  (duration 1)
  (effects
    (strike-body
      (do (yield-evidence @self ?foe torso puncture_wound) (kill-blow ?foe stab))
      (do (yield-evidence @self ?foe right_hand puncture_wound)
          (if (chance (blow_succumb_prob)) (then (kill-blow ?foe stab)))))
    (set-outcome {@self STAB ?foe} succ)))

; SLASH - an edged blade drawn across (kill intent). knife_fighting.
(npc-action {@self SLASH ?foe}
  (obs)
  (theme violent_to)
  (duration 1)
  (effects
    (strike-body
      (do (yield-evidence @self ?foe head slash_wound) (kill-blow ?foe slash))
      (do (yield-evidence @self ?foe right_hand slash_wound)
          (if (chance (blow_succumb_prob)) (then (kill-blow ?foe slash)))))
    (set-outcome {@self SLASH ?foe} succ)))

; SHOOT - a firearm discharge (kill intent). marksmanship.
(npc-action {@self SHOOT ?foe}
  (obs)
  (theme violent_to)
  (duration 1)
  (effects
    (strike-body
      (do (yield-evidence @self ?foe head puncture_wound) (kill-blow ?foe shoot))
      (do (yield-evidence @self ?foe right_hand puncture_wound)
          (if (chance (blow_succumb_prob)) (then (kill-blow ?foe shoot)))))
    (set-outcome {@self SHOOT ?foe} succ)))

; BLUDGEON - a blunt instrument to the skull (kill intent). pugilism.
(npc-action {@self BLUDGEON ?foe}
  (obs)
  (theme violent_to)
  (duration 1)
  (effects
    (strike-body
      (do (yield-evidence @self ?foe head blunt_wound) (kill-blow ?foe bludgeon))
      (do (yield-evidence @self ?foe torso blunt_wound)
          (if (chance (blow_succumb_prob)) (then (kill-blow ?foe bludgeon)))))
    (set-outcome {@self BLUDGEON ?foe} succ)))

; STRANGLE - manual / ligature asphyxiation (kill intent). wrestling.
(npc-action {@self STRANGLE ?foe}
  (obs)
  (theme violent_to)
  (duration 1)
  (effects
    (strike-body
      (do (yield-evidence @self ?foe head ligature_mark) (kill-blow ?foe strangle))
      (do (yield-evidence @self ?foe head ligature_mark)
          (if (chance (blow_succumb_prob)) (then (kill-blow ?foe strangle)))))
    (set-outcome {@self STRANGLE ?foe} succ)))

; SMOTHER - a soft implement over the airway (kill intent). wrestling.
(npc-action {@self SMOTHER ?foe}
  (obs)
  (theme violent_to)
  (duration 1)
  (effects
    (strike-body
      (do (yield-evidence @self ?foe head bruise) (kill-blow ?foe smother))
      (do (yield-evidence @self ?foe head bruise)
          (if (chance (blow_succumb_prob)) (then (kill-blow ?foe smother)))))
    (set-outcome {@self SMOTHER ?foe} succ)))

; PUNCH - the NET-NEW non-lethal blow (subdue intent): a solid hit KNOCKS OUT (writes
; awareness unconscious - the consequence the subdue wound rows always emitted but
; nothing consumed); a graze only bruises. Never fatal, no succumb roll. pugilism.
(npc-action {@self PUNCH ?foe}
  (obs)
  (theme violent_to)
  (duration 1)
  (effects
    (strike-body
      (do (yield-evidence @self ?foe head bruise) (set-attr ?foe awareness unconscious))
      (yield-evidence @self ?foe torso bruise))
    (set-outcome {@self PUNCH ?foe} succ)))
