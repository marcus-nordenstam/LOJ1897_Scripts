; ----------------------------------------------------------------------------
; strangle (npc-task) - a killing method proposed by choose_kill_method off a standing
; kill goal. Bare-handed: reach the victim, then CHOKE until they are dead. The blows
; (CHOKE) are the (obs) witnessed violent acts that carry the blame; this task is the
; actor's plan, not a witnessed act, so it needs no decoration of its own. Concludes
; bottom-up on the victim's death (this hand's grip, or another's - the goal is moot).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-task {@self strangle ?victim}:?strangle
  (tar human)
  (and
    ; REACH: route to the victim's known location, else their home.
    (try
      (when (and (not (co-present ?victim @self))
                 (not (believes {?victim condition [k dead]}))
                 (location ?victim): ?loc))
      (utility survival)
      (effects (maintain-proposal {@self go ?loc})))
    (try
      (when (and (not (co-present ?victim @self))
                 (not (believes {?victim condition [k dead]}))
                 (unknown (location ?victim))))
      (utility survival)
      (effects (maintain-proposal {@self go (home-of ?victim)})))

    ; THE BLOW: co-present with a living victim - CHOKE the life out of them.
    (try
      (when (and (co-present ?victim @self)
                 (not (believes {?victim condition [k dead]}))))
      (utility survival always-pick)
      (effects (maintain-proposal {@self CHOKE ?victim})))

    ; CONCLUDE: the victim is dead - the method is spent.
    (try
      (when (believes {?victim condition [k dead]}))
      (effects (set-outcome ?strangle succ)))))
