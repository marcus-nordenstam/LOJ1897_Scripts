; ----------------------------------------------------------------------------
; go - the shared TRAVEL act body. Any lane that needs the actor somewhere it is not
; maintains {@self go <dest>} (as a sub-goal of the thing it is really after - drink /
; worship / an errand); that goal, being the live leaf, promotes to go_act, which spends
; the travel time and relocates the actor on completion. Not owned by any one lane.
;
; While a find_building search stands, go_act ALSO marks its arrival building surveyed.
; The search's own hop lives in npc-act/find_building.hs (find_building_act walks and
; marks directly); this arrival-marking covers the ERRAND case: any building the searcher
; reaches for another reason counts - it has been there and exterior-perceived its
; neighbours, so it drops out of the frontier.
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
    (end-act {@self go ?dest})
    ; Drain the go SUB-GOAL on arrival (?dest is bound here). Formerly excl_goal_sweep
    ; retracted it; the routing rung is now a scheduled maintenance event that holds its
    ; rouletted destination, so the arrival act ends the concrete go-goal it fulfilled.
    (end-goal {@self go ?dest})))

; go_to_threshold - the counterpart DUMB travel primitive: reach a structure's THRESHOLD
; (front-park ~1m OUTSIDE its face), never a room center. The enter chain (enter.hs) mints
; {@self go_to_threshold ?s} to bring the actor to a venue's door, where at-threshold reads
; true and perception teaches the entrance; enter_step_in then steps inside. relocate only
; drops an actor at a target's CENTER (inside), so front-park is the ONLY op that yields an
; outside point - hence a separate act, not a branch inside go_act. The completion pass
; force-ends the act-belief; the minter (enter_go_to_threshold) ends the go_to_threshold GOAL
; on its falling edge, so this act carries no end-act / end-goal.
(npc-act go_to_threshold_act
  (when (believes {@self go_to_threshold ?s}))
  (duration (max (go_travel_floor_min) (travel-minutes @self ?s)))
  (act-effects
    (front-park @self ?s)
    ; Cross-subsidy (§5.11): a front-park while a find_building search stands ALSO surveys
    ; ?s - its exterior is perceived from the threshold - keeping the search frontier fed,
    ; the coverage the old two-arm go_act gave on a building arrival.
    (if (goal? {@self find_building ?})
        (bb-mark ?s surveyed (survey_marker_ttl_cycles)))))
