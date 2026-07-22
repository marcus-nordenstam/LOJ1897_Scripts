; ----------------------------------------------------------------------------
; find_building (npc-action lane) - the GENERIC building-discovery search, and the ACT
; that walks it. A seek rule (drink_find / worship_find / convey_find / ...) maintains
; {@self goal {@self find_building [k building <kind>]}} while it wants a venue of a
; kind it knows NONE of. The goal IS the walking leaf.
;
; PURE acts (act_body_purification): the deliberation - which vantage to survey next -
; lives in find_building_think.hs. find_survey casts the NEAREST unsurveyed known
; building (policy argmin) and PROPOSES {@self find_building ?sought ?next}, so ?next
; arrives on the act-belief AUX; this body spends the won slot walking there, surveying,
; and marking the vantage spent. find_stall is the idle terminal find_stall proposes
; when NO unsurveyed building is known.
;
; The ?next carried on the act-belief aux is an ABS handle (the act-belief externalises
; so co-present minds can perceive the walk); (bb-mark ?next surveyed) resolves it back
; to the SAME mental object find_survey's (bb-none ?next surveyed) role reads (resolve_bb_
; host reuses the abs->mental LUT link), so the marker excludes the vantage from the next
; pick and the search crawls outward through REACHABLE territory one hop at a time. The
; arrival exterior-perception (perceive_here's outdoor branch) surveys the vantage and
; mints the UNKNOWN buildings around it. Several find goals can stand at once; whichever
; wins walks, and one survey hop advances every standing search (the marker is
; kind-agnostic). The marker is TTL'd (survey_marker_ttl_cycles months) so only ACTIVE
; searchers hold markers. go_act ALSO marks its arrival surveyed while a find goal stands.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")
(include "../../macros/tunables.hs")

(npc-action find_building_act
  (act {@self find_building ?sought ?next})
  (duration (max (go_travel_floor_min) (travel-minutes @self ?next)))
  (act-effects
    (front-park @self ?next)
    (bb-mark ?next approached)
    (bb-mark ?next surveyed (survey_marker_ttl_cycles))
    (end-act {@self find_building ?sought})))

; TERMINAL - no unsurveyed building known (find_survey cast no ?next): idle briefly,
; then re-deliberate. Ends its own act-belief so the find goal it serves stays live.
(npc-action find_stall_act
  (act {@self find_stall ?sought})
  (duration 60)
  (act-effects (end-act {@self find_stall ?sought})))
