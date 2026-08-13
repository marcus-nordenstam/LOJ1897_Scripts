; ----------------------------------------------------------------------------
; locate ?thing ?bldg - come to KNOW where ?thing is INSIDE ?bldg. ?thing may be a
; concrete object OR a kind ([k mail_stack] matches any mail_stack). While @self
; holds no belief placing a ?thing in ?bldg (the location.building chain), wander
; ?bldg: its room-walk perceives every room's contents, teaching {?thing location}
; on arrival in ?thing's room. The chain scopes to ?bldg, so knowing some OTHER
; building's mail stack does not satisfy a locate of THIS building's. The moment the
; location is known the wander maintain evaporates and locate concludes.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think locate_wander
  (task {@self locate ?thing ?bldg}:?loc)
  (when (none {?thing location.building ?bldg}))
  (effects (maintain-proposal {@self wander ?bldg})))

(npc-think locate_done
  (task {@self locate ?thing ?bldg}:?loc)
  (when (believes {?thing location.building ?bldg}))
  (effects (set-outcome ?loc succ)))
