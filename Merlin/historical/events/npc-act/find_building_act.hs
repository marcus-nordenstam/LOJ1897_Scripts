; ----------------------------------------------------------------------------
; find_building (npc-act lane) - the terminal idle act of the GENERIC building-
; discovery search. The frontier-step think lives in npc-think/find_building.hs.
;
; find_building_exhausted is the terminal: when every KNOWN building is already
; surveyed, find_building_step casts no ?next, so the find goal (now a childless
; leaf) promotes here and idles until a marker expires or a new building is
; perceived, then the sweep resumes.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

; TERMINAL - no unsurveyed building known: idle briefly, then re-deliberate (a marker may
; have expired, or a perceived neighbour re-opened the frontier). Ends the act-belief so
; the seek goal it serves stays live for the next attempt.
(npc-act find_building_exhausted
  (when (believes {@self find_building ?sought}))
  (duration 60)
  (act-effects (end-act {@self find_building ?sought})))
; go_act (travel + arrival survey/mark while a find goal stands) lives in npc-act/go.hs.
