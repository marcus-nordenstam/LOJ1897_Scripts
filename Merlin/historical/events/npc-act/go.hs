; ----------------------------------------------------------------------------
; go - the shared TRAVEL act body. Any lane that needs the actor somewhere it is not
; maintains {@self go <dest>} (as a sub-goal of the thing it is really after - drink /
; worship / an errand); that goal, being the live leaf, promotes to go_act, which spends
; the travel time and relocates the actor on completion. Not owned by any one lane.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-act go_act
  (when (believes {@self go ?dest}))
  (duration (travel-minutes @self ?dest))
  (effects
    (relocate @self ?dest)
    (end-act {@self go ?dest})))
