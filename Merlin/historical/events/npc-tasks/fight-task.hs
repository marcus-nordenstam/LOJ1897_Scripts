; ----------------------------------------------------------------------------
; fight (npc-task) - the confrontation episode, morally NEUTRAL (batch-3 Lane 1).
; Both the aggressor and a defender who engages run this SAME task; neither the
; fight nor the strike ACTIONS it proposes carry wrong_act. Blame lives only on
; the `assault` task that CAUSED the fight (see assault-task.hs): the aggressor's
; fight is /caused_by his own {@self assault ?foe}; a defender's fight is
; /caused_by the WITNESSED {?foe assault @self} - "why were you fighting John?
; because John assaulted me." A ten-blow brawl is now ten ended strike acts under
; ONE ended fight task (the episode as a unit), not ten {@self fight} acts.
;
; Per blow it proposes the CHOSEN attack action from the family: the weapon-class
; method choose_kill_method picked (firearm -> SHOOT, bare-strangle -> STRANGLE),
; else a bare-handed STRIKE. The strike actions carry the class's own physics.
; fight_concluded is the OUTCOME twin: the foe's death ends the episode.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-task {@self fight ?foe}:?fight
  (tar human)
  (and
    ; REACH the foe if the fight is standing but the foe slipped away (a killer
    ; stalking a fled victim); a co-present fight needs no travel.
    (try
      (when (and (not (co-present ?foe @self))
                 (not (believes {?foe condition [k dead]}))
                 (location ?foe): ?loc))
      (utility survival)
      (effects (maintain-proposal {@self go ?loc})))

    ; THE BLOW: co-present with a living foe, propose the chosen attack action.
    ; The method belief (choose_kill_method) holds the strike ACTION itself, so
    ; the blow is a direct dispatch {@self ?method ?foe} - add a weapon class by
    ; naming its action in kill_method_choice, no rung edit here.
    (try
      (when (and (co-present ?foe @self)
                 (not (believes {?foe condition [k dead]}))
                 (believes {@self method ?method})))
      (utility survival always-pick)
      (effects (maintain-proposal {@self ?method ?foe})))

    ; A defender (no chosen method) falls to a bare-handed STRIKE.
    (try
      (when (and (co-present ?foe @self)
                 (not (believes {?foe condition [k dead]}))
                 (not (believes {@self method ?}))))
      (utility survival always-pick)
      (effects (maintain-proposal {@self STRIKE ?foe})))

    ; fight_concluded: the foe is dead (this hand's fatal blow, or another's) -
    ; the episode is over. The killer's own dead-percept fires this at his next
    ; deliberation; a victorious defender's too.
    (try
      (when (believes {?foe condition [k dead]}))
      (effects (set-outcome ?fight succ)))))
