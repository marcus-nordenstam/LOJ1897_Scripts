; ----------------------------------------------------------------------------
; strangle (npc-task) - a killing method the kill task proposes (argmax over
; kill_method_table). Bare-handed: reach the victim, then CHOKE until they are dead. The blows
; (CHOKE) are the (obs) witnessed violent acts that carry the blame; this task is the
; actor's plan, not a witnessed act, so it needs no decoration of its own. Concludes
; bottom-up on the victim's death (this hand's grip, or another's - the goal is moot).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")

(npc-task {@self strangle ?victim}:?strangle-rel
  (track-skill-level [k garrotting])
  (tar human)
  (and
    ; REACH: route to the victim's known location, else their home.
    (try
      (when (and (not (spatial ?victim co-located @self))
                 -{?victim condition [k dead]}
                 (spatial ?victim space): ?loc))
      (utility survival)
      (effects (maintain-proposal {@self go ?loc})))
    (try
      (role ?vhome {?victim home ?vhome})
      (when (and (not (spatial ?victim co-located @self))
                 -{?victim condition [k dead]}
                 (unknown (spatial ?victim space))))
      (utility survival)
      (effects (maintain-proposal {@self go ?vhome})))

    ; THE BLOW: co-present with a living victim - CHOKE the life out of them.
    (try
      (when (and (spatial ?victim co-located @self)
                 -{?victim condition [k dead]}))
      (utility survival always-pick)
      (effects (maintain-proposal {@self STRIKE ?victim strangle})))

    ; CONCLUDE: the victim is dead - the method is spent.
    (try
      (when {?victim condition [k dead]})
      (effects (set-outcome ?strangle-rel /succ)))))
