; ----------------------------------------------------------------------------
; locate ?thing ?bldg - come to KNOW where ?thing is INSIDE ?bldg. ?thing may be a
; concrete object OR a kind ([k mail_stack] matches any of that kind). While @self
; believes no ?thing is in ?bldg ((in-building ?thing ?bldg) reads the spatial index -
; an entity subject resolves its own building, a kind subject matches any occupant of
; that kind), wander ?bldg: its room-walk perceives every room's contents, teaching
; {?thing location} on arrival in ?thing's room. The query scopes to ?bldg, so knowing
; some OTHER building's mail stack does not satisfy a locate of THIS building's. The
; moment the location is known the wander maintain evaporates and locate concludes.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think locate_wander
  (task {@self locate ?thing ?bldg}:?loc)
  (when (not (in-building ?thing ?bldg)))
  (effects (maintain-proposal {@self wander ?bldg})))

(npc-think locate_done
  (task {@self locate ?thing ?bldg}:?loc)
  (when (in-building ?thing ?bldg))
  (effects (set-outcome ?loc succ)))
