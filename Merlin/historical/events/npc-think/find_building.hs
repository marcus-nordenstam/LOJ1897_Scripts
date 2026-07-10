; ----------------------------------------------------------------------------
; find_building - the GENERIC building-discovery search (the deepest rung of the "get to
; a venue of kind K" cascade). A seek rule (e.g. crave_drink's drink_find, worship_find)
; maintains {@self goal {@self find_building [k building <kind>]}} when it wants a venue of
; a kind it knows NONE of. That goal drives an ACTIVE FRONTIER SEARCH:
;
;   find_building_step (a think gated on the find goal) casts ?next = the FARTHEST KNOWN
;   building it has NOT yet surveyed and maintains {@self go ?next}. That go promotes to
;   go_act, which TRAVELS there and front-parks; the arrival perceive_here surveys the
;   vantage and mints the UNKNOWN buildings around it (they enter the ?next role via the
;   belief-write reconcile), and go_act marks ?next surveyed BECAUSE a find goal stands.
;   Preferring the FARTHEST vantage (not the nearest) leaps to the edge of known territory
;   each step, so a survey there reveals a fresh ring of unknown buildings - the fringe fans
;   outward in FEWER hops than dawdling among near buildings would. Repeat until a building
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
;
; find_building_exhausted is the terminal: when every KNOWN building is already surveyed,
; find_building_step casts no ?next, so the find goal (now a childless leaf) promotes here
; and idles until a marker expires or a new building is perceived, then the sweep resumes.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-think find_building_step
  (short-term-think)
  (goal    {@self find_building ?sought})
  (role @self (grown @self))
  (role ?next [k building]
        (bb-none ?next surveyed)
        (prefer (distance @self ?next)) (policy argmax))
  (cont-fire-effects (excl-goal {@self go ?next})))

; TERMINAL - no unsurveyed building known: idle briefly, then re-deliberate (a marker may
; have expired, or a perceived neighbour re-opened the frontier). Ends the act-belief so
; the seek goal it serves stays live for the next attempt.
(npc-act find_building_exhausted
  (when (believes {@self find_building ?sought}))
  (duration 60)
  (effects (end-act {@self find_building ?sought})))
; go_act (travel + arrival survey/mark while a find goal stands) lives in npc-act/go.hs.
