; ----------------------------------------------------------------------------
; find_building (npc-act lane) - the GENERIC building-discovery search: the
; deepest rung of the "get to a venue of kind K" cascade, and the ACT that
; walks it. A seek rule (e.g. crave_drink's drink_find, worship's worship_find)
; maintains {@self goal {@self find_building [k building <kind>]}} while it
; wants a venue of a kind it knows NONE of. The goal IS the walking leaf -
; there is no go sub-goal rung. Whichever find goal wins the motor promotes
; HERE and spends its slot on ONE survey hop:
;
;   find_building_act casts ?next = the NEAREST known building this mind has
;   not yet surveyed (policy argmin), travels there and front-parks; the
;   arrival exterior-perception (perceive_here's outdoor branch) surveys the
;   vantage and mints the UNKNOWN buildings around it, and the hop marks ?next
;   surveyed. Preferring the nearest unsurveyed vantage crawls outward through
;   REACHABLE territory one hop at a time. Repeat until a building of the
;   sought kind is learned; the instant it is, the seek rule's (no-role ...)
;   fills, it stops firing, its excl-goal drops the find goal, and the seek
;   lane's go rung takes over.
;
;   The ACT (not a think-minted go sub-goal) owns the hop because SEVERAL find
;   goals can stand at once (a pub search and a church search): each competes
;   with its own inherited drive, and WHICHEVER wins walks - one survey hop
;   advances every standing search, since the surveyed marker is kind-agnostic.
;   (A single shared go sub-goal could only /cause-inherit ONE goal's drive;
;   the other goal, a childless leaf, promoted to the idle terminal below and
;   burned its whole motor slot standing still.)
;
; The `surveyed` marker is a PRIVATE-BB entry on each building's mental object
; (not a belief): bookkeeping - which vantages this search has spent -
; invisible to other minds, dirtying the object cache so the ?next role
; re-materializes on mark/expiry. It is TTL'd (survey_marker_ttl_cycles
; months): a marker outlives one coverage sweep but self-reclaims once the
; search ends, so only ACTIVE searchers hold markers and the bb pool stays
; bounded. When it expires the building becomes re-explorable - a town's
; layout is not learned once. go_act ALSO marks its arrival surveyed while a
; find goal stands (an errand arrival is a survey too).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")
(include "../../macros/tunables.hs")

; ONE survey hop: walk to the nearest unsurveyed known building, front-park,
; survey. Ends the act-belief; the find GOAL persists (the seek rule maintains
; it), so the next won slot hops again.
(npc-act find_building_act
  (role @self (believes {@self find_building ?sought}))
  (role ?next [k building]
        (bb-none ?next surveyed)
        (select (score (distance @self ?next)) (policy argmin)))
  (duration (max (go_travel_floor_min) (travel-minutes @self ?next)))
  (act-effects
    (front-park @self ?next)
    (bb-mark ?next approached)
    (bb-mark ?next surveyed (survey_marker_ttl_cycles))
    (end-act {@self find_building ?sought})))

; TERMINAL - no unsurveyed building known (the hop's role cast no ?next): idle
; briefly, then re-deliberate (a marker may have expired, or a perceived
; neighbour re-opened the frontier). Ends the act-belief so the seek goal it
; serves stays live for the next attempt.
(npc-act find_building_exhausted
  (when (believes {@self find_building ?sought}))
  (duration 60)
  (act-effects (end-act {@self find_building ?sought})))
