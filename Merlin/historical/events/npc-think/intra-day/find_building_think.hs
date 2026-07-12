; ----------------------------------------------------------------------------
; find_building (npc-think lane) - the GENERIC building-discovery search (the deepest rung
; of the "get to a venue of kind K" cascade). The terminal idle act lives in
; npc-act/find_building.hs. A seek rule (e.g. crave_drink's drink_find, worship_find)
; maintains {@self goal {@self find_building [k building <kind>]}} when it wants a venue of
; a kind it knows NONE of. That goal drives an ACTIVE FRONTIER SEARCH:
;
;   find_building_step (a think gated on the find goal) casts ?next = the FARTHEST KNOWN
;   building it has NOT yet surveyed and maintains {@self go ?next}. That go promotes to
;   go_act, which TRAVELS there and front-parks; the arrival perceive_here surveys the
;   vantage and mints the UNKNOWN buildings around it (they enter the ?next role via the
;   belief-write reconcile), and go_act marks ?next surveyed BECAUSE a find goal stands.
;   Preferring the NEAREST unsurveyed vantage (policy argmin) crawls outward through
;   REACHABLE territory one hop at a time. Picking the farthest instead lets a searcher
;   fixate on a distant vantage it never actually arrives at, so its survey never advances
;   and its markers pile up until the private-bb pool overflows. Repeat until a building
;   of the sought kind is learned; the instant it is, the seek rule's (no-role ...) fills,
;   it stops firing, its excl-goal drops the find goal, and the go-rung takes over.
;
;   The marking lives in go_act, NOT here: find_building_step never marks, so ?next stays
;   STABLE across re-deliberations (a hop that loses the motor is re-held by the same
;   excl-goal, not re-picked) - that is what stops the frontier sweep from churning markers.
;
; The `surveyed` marker is a PRIVATE-BB entry on each building's mental object (not a
; belief): bookkeeping - which vantages this search has spent - invisible to other minds,
; dirtying the object cache so the ?next role re-materializes on mark/expiry. It is TTL'd
; (survey_marker_ttl_cycles months): a marker outlives one coverage sweep but self-reclaims
; once the search ends, so only ACTIVE searchers hold markers and the bb pool stays bounded.
; When it expires the building becomes re-explorable - a town's layout is not learned once.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think find_building_step
  (short-term-think)
  (goal    {@self find_building ?sought})
  (role @self (grown @self))
  (role ?next [k building]
        (bb-none ?next surveyed)
        (select (score (distance @self ?next)) (policy argmin)))
  (cont-fire-effects (excl-goal {@self go ?next})))
