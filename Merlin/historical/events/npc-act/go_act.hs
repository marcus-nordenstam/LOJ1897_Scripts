; ----------------------------------------------------------------------------
; go - the shared TRAVEL act body. Any lane that needs the actor somewhere it is not
; maintains {@self go <dest>} (as a sub-goal of the thing it is really after - drink /
; worship / an errand); that goal, being the live leaf, promotes to go_act, which spends
; the travel time and relocates the actor on completion. Not owned by any one lane.
;
; While a find_building search stands, go_act ALSO marks its arrival building surveyed:
; find_building_step just maintains {@self go <unsurveyed building>} and NEVER marks, so
; its target stays stable across re-deliberations (a search hop that loses the motor is
; simply re-maintained, not re-picked) - marking on ARRIVAL here is what keeps the frontier
; sweep from churning markers. Any building the searcher reaches (errand or survey) counts:
; it has been there and exterior-perceived its neighbours, so it drops out of the frontier.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")
(include "../../macros/tunables.hs")

(npc-act go_act
  (when (believes {@self go ?dest}))
  (duration (max (go_travel_floor_min) (travel-minutes @self ?dest)))
  (act-effects
    ; TWO-ARM ARRIVAL (Stage 5), entirely in this ONE act. A BUILDING is ALWAYS FRONT-
    ; PARKED ~1m outside - never entered directly - so the arrival exterior-perception
    ; (perceive_here's outdoor branch) RE-OBSERVES the building every visit: its perceptible
    ; state (struct_status open|closed, and future changes) and, via the entrance seam, a
    ; room to step into. Front-parking marks a per-trip `approached` private-bb flag on the
    ; building; the routing macro (route-to-venue-then-act / go-into) reads it to fire the
    ; SECOND arm - (go ?room) - which ENTERS a room and clears the flag (so the next visit
    ; re-front-parks and re-observes). A ROOM / space dest is entered.
    (if (is-a ?dest [k building])
        (do (front-park @self ?dest)
            (bb-mark ?dest approached))
        (do (relocate @self ?dest)
            (bb-clear (current-building @self) approached)))
    (if (goal? {@self find_building ?})
        (bb-mark ?dest surveyed (survey_marker_ttl_cycles)))
    (end-act {@self go ?dest})))
