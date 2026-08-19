; ----------------------------------------------------------------------------
; shoot (npc-task) - a killing method proposed by choose_kill_method off a standing kill
; goal, chosen when a firearm's whereabouts is known. ARM first (means_plan_acquire drives
; the shop errand while this task runs and @self holds no firearm), then reach the victim
; and TRIGGER_FIREARM until dead. The reach + shot rungs gate on being ARMED, so an unarmed
; shooter does not chase the victim empty-handed - it fetches the gun first. The blows
; (TRIGGER_FIREARM) are the (obs) witnessed acts that carry the blame.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-task {@self shoot ?victim}:?shoot-rel
  (tar human)
  (and
    ; REACH (armed only): route to the victim's known location, else their home.
    (try
      (when (and (not (co-present ?victim @self))
                 (not (empty (spatial @self hold [k firearm])))
                 (not (believes {?victim condition [k dead]}))
                 (location ?victim): ?loc))
      (utility survival)
      (effects (maintain-proposal {@self go ?loc})))
    (try
      (when (and (not (co-present ?victim @self))
                 (not (empty (spatial @self hold [k firearm])))
                 (not (believes {?victim condition [k dead]}))
                 (unknown (location ?victim))))
      (utility survival)
      (effects (maintain-proposal {@self go (home-of ?victim)})))

    ; THE SHOT: armed, co-present with a living victim - fire.
    (try
      (when (and (co-present ?victim @self)
                 (not (empty (spatial @self hold [k firearm])))
                 (not (believes {?victim condition [k dead]}))))
      (utility survival always-pick)
      (effects (maintain-proposal {@self TRIGGER_FIREARM ?victim})))

    ; CONCLUDE: the victim is dead - the method is spent.
    (try
      (when (believes {?victim condition [k dead]}))
      (effects (set-outcome ?shoot-rel succ)))))
