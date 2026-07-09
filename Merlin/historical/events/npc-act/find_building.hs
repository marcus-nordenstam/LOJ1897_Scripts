; ----------------------------------------------------------------------------
; find_building - the GENERIC building-discovery act (the deepest rung of the "get to a
; venue of kind K" cascade). A seek rule (e.g. crave_drink's drink_find) maintains
; {@self goal {@self find_building [k building <kind>]}} when it wants a venue of a kind it
; knows NONE of. That goal, being the live leaf, promotes to find_building_act:
;
;   find_building_act travels out and FRONT-PARKS at its current building - the arrival
;   exterior-perceive learns the UNKNOWN buildings nearby. As the actor goes about its day
;   (home / work / errands) the survey covers those neighbourhoods; the instant a building
;   of the sought kind is learned, the seek rule's (no-role ...) fills, it stops firing,
;   its maintain-goal drops support for the find goal, and the go-rung takes over.
;
; Kind-agnostic: the act just grows the known-building set. The sought kind rides in the
; act-belief (?sought) but the survey does not use it - it is the seek rule's no-role that
; decides "found". front-park is an ACT-phase effect (externalizes legitimately).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-act find_building_act
  (when (believes {@self find_building ?sought}))
  (duration 30)
  (effects
    (front-park @self (current-building @self))
    (end-act {@self find_building ?sought})))
