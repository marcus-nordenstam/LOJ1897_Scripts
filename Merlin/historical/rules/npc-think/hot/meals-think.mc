; ----------------------------------------------------------------------------
; meals - the npc-THINK half of the UNIFIED eat lane (the acts + the meals-local
; define-macros live in npc-act/meals.hs). This file holds the meal desires, the
; at-home idle yield, the shared approach (eat_go), the provisioning approach
; desires, and the starvation-tail desires.
;
; ONE act-goal serves every routine meal: {@self eat [k <meal>] <place>} - a
; desire mints it in its window; the <place> drives a leaf-first approach (eat_go);
; at the place it promotes to the shared eat_act (npc-act/meals.hs).
;
; UTILITY IS PROXIMITY TO THE MEALTIME, NEVER HUNGER (ruling 10): each desire is
; eligible only inside its believed window. Hunger is pure physiology - it
; accrues at the completion seam (sleep included - you wake hungry) and each
; meal reduces it - and enters the lanes only as the ELIGIBILITY gate
; (> hunger 0.25): just-fed NPCs skip the next window (the once-per-window dedup).
;
; FOOD KNOWLEDGE IS PER-MIND (the no-omniscience rule): every stock gate reads
; the asker's OWN belief about the home larder PILE via (believed-home-food-count
; <home>) - the count it has perceived on the kitchen food pile, never a world
; scan - and the supper consume decrements that pile. Keep the count read LAST in
; each (when) so the belief walk only runs on otherwise-eligible NPCs.
;
; THREE MEALS (ruling 13):
;   breakfast  - at home, 30 min, come-as-you-wake (3h window). Utility 82 - a
;                shade over the work lane so the commuter eats before leaving.
;   lunch      - one meal-kind, two places: at the workplace at midday (util 85,
;                the co-worker channel) OR at home per lunch_hour (util 76).
;   supper     - the FAMILY table, 60 min. Utility 78: under work's 80, over
;                leisure. The window opens an hour early so eat_go's travel
;                (30 min) lands the household home by the cook's hour. When the
;                diner KNOWS of no food at home + wealth permits, EATING OUT
;                mints the same supper goal at a pub / restaurant instead
;                (util 70) - the venue kitchen is abstract (no prop consumed).
; ----------------------------------------------------------------------------

; ------------------------------------------------------- the mealtime yield

; idle_at_home - the at-home idle, CAPPED to yield at the household's next
; mealtime. Intra-day eligibility is only sampled at act completions, so an
; uncapped multi-hour idle leaps clean over a 2h meal window (the engine's
; bare fallback idles in 3h blocks - the household would idle straight past
; supper). This authored idle owns the at-home nothing-to-do slot and ends
; at the next meal hour, so the meal lanes get their deliberation instant.
; An unknown mealtime contributes a huge sentinel (minutes-until-hour) and
; drops out of the (min ...).
(npc-think idle_at_home
  (role ?home {@self home ?home})
  (when (at-home))
  (utility idle fallback)
  (effects       (begin-goal {@self DWELL ?home}))
  (cease-effects (end-goal   {@self DWELL ?home})))

; TERMINAL step (act_body_purification): the at-home dwell is now PROPOSED, guarded by being at
; home, not auto-promoted by the bare {@self DWELL ?home} goal. idle_at_home holds the goal (util
; 2, the at-home nothing-to-do slot); the dwell promotes ONLY here, ONLY at home. The proposal
; inherits the idle utility from the {@self DWELL ?home} goal it /causes (via the (goal ...) gate).
; The idle blocks, one per canonical meal window, each aimed at its ABSOLUTE
; boundary hour (the eat lanes decide the actual eating at those completions;
; a household's own +-1h mealtime shift just moves who wins the boundary).
; Per-window (when)s fell each bout at its boundary, so a resumed dwell never
; carries a stale ?until across windows; post-supper the block runs to
; midnight and the sleep lane takes over long before.
(npc-think dwell_at_home_morning
  (goal    {@self DWELL ?home})
  (when    (and (at-home) (< (now-hour) 12)))
  (effects (maintain-proposal {@self DWELL ?home 12})))

(npc-think dwell_at_home_afternoon
  (goal    {@self DWELL ?home})
  (when    (and (at-home) (>= (now-hour) 12) (< (now-hour) 18)))
  (effects (maintain-proposal {@self DWELL ?home 18})))

(npc-think dwell_at_home_evening
  (goal    {@self DWELL ?home})
  (when    (and (at-home) (>= (now-hour) 18)))
  (effects (maintain-proposal {@self DWELL ?home 24})))

; ============================ the unified eat lane ==========================
; Every routine meal is ONE act-goal {@self eat [k <meal>] <place>}: a desire
; mints it in its window, the <place> drives a leaf-first approach (eat_go), and
; at the place the goal promotes to the shared eat_act. The begun-then-ended
; act-belief IS the meal memory (target = the meal occasion, aux = the place);
; there is no separate dine record.

(include "../../../macros/intensity-macros.mc")
(include "../../../macros/collection-macros.mc")
(include "../../../macros/money-macros.mc")

; THE STARVATION DRIVE - the banded escalation ladder for hunger past its window.
; The starving tail (below) all gate on appetite > 1.3, so this always sits in the
; CRISIS band (starving is an acute emergency, above every routine need); the ladder
; keeps the sub-need shape for any future re-gating. Value climbs convex toward collapse.
(define-macro starve-drive ()
  (homeostatic-banded appetite 2.0
    (want   0.0  0   500)
    (need   0.45 300 900)
    (crisis 0.9  600 1000)))

; ---- notice the larder -----------------------------------------------------
; A home, hungry resident who believes there is NO food OBSERVES their own
; kitchen (the larder room), surfacing its contents into belief. Without this
; only the cook - who stocks and frequents the kitchen - knows the food is there;
; the rest of the family believes an empty larder, skips the family table, and
; starves beside a full kitchen. Per-mind honest (you check your own kitchen when
; hungry at home) and un-gated by food belief (LEARNING whether food is there is
; the whole point). Self-limiting: once the food is seen the count is > 0 and this
; stops firing until the larder is eaten down again; a truly empty kitchen keeps
; reading 0 and the resident falls through to the meal-less lanes, as it should.
(npc-think notice_larder
  (role ?home {@self home ?home})
  (when (and (at-home)
             (> (attr @self appetite) 0.25)
             (= (believed-home-food-count ?home) 0)
             (spatial ?home room [k kitchen]): ?kitchen))   ; a resident who does not know their kitchen just skips
  (effects
    (observe ?kitchen)))

; ---- the meal desires (mint {@self eat [k <meal>] <place>}) ----------------

; BREAKFAST - at home, come-as-you-wake (3h window, the one exception to the 2h
; rule): you breakfast in the house you woke in or not at all.
(npc-think want_breakfast
  (role ?home {@self home ?home}
              {?home breakfast_hour ?h})   ; existence cached, ?h binds at fire
  (when (and (at-home)
             (> (attr @self appetite) 0.25)
             (>= (now-hour) ?h)
             (< (now-hour) (+ ?h 3))
             (> (believed-home-food-count ?home) 0)))
  (utility need)
  (effects       (begin-goal {@self eat [k breakfast] ?home}))
  (cease-effects (end-goal   {@self eat [k breakfast] ?home})))

; LUNCH at the workplace - the CO-WORKER channel (eat where you stand at midday).
(npc-think want_lunch_work
  (role ?job {@self job ?job})
  (role ?org {?job org ?org}           ; produced-restricted: ?org threaded off ?job
             {?org workplace ?wp}       ; ?wp binds at fire
             (spatial @self building ?wp))                    ; residual gate, re-checked at the when-seam
  (when (and (> (attr @self appetite) 0.25)
             (>= (now-hour) 12)
             (< (now-hour) 14)))
  (utility need)
  (effects       (begin-goal {@self eat [k lunch] ?wp}))
  (cease-effects (end-goal   {@self eat [k lunch] ?wp})))

; LUNCH at home - the jobless / housewife / child midday meal, per lunch_hour.
(npc-think want_lunch_home
  (role ?home {@self home ?home}
              {?home lunch_hour ?h})   ; existence cached, ?h binds at fire
  (when (and (at-home)
             (> (attr @self appetite) 0.25)
             (>= (now-hour) ?h)
             (< (now-hour) (+ ?h 2))
             (> (believed-home-food-count ?home) 0)))
  (utility need)
  (effects       (begin-goal {@self eat [k lunch] ?home}))
  (cease-effects (end-goal   {@self eat [k lunch] ?home})))

; SUPPER at home - the FAMILY table. The window opens an hour early so eat_go's
; travel (30 min) lands the household home by the cook's hour.
(npc-think want_supper
  (role ?home {@self home ?home}
              {?home supper_hour ?h})   ; existence cached, ?h binds at fire
  (when (and (> (attr @self appetite) 0.25)
             (>= (now-hour) (- ?h 1))
             (< (now-hour) (+ ?h 2))
             (> (believed-home-food-count ?home) 0)))
  (utility need)
  (effects       (begin-goal {@self eat [k supper] ?home}))
  (cease-effects (end-goal   {@self eat [k supper] ?home})))

; EATING OUT - no food at home (as the diner KNOWS) in the supper window and
; wealth permits: a pub supper (lower/middle), a restaurant one (upper). The
; venue is the eat place; eat_go walks there. Utility 70: under the home supper
; (whose stock gate already failed if this is eligible), over leisure.
(npc-think want_eat_out_pub
  ; class gate = CACHED self-gate filter (the belief form, not the live conjunct).
  (role @self {@self wealth ?wealth} 
              -{@self class_situation [k upper]})
  (role ?home {@self home ?home}
              {?home supper_hour ?h})   ; existence cached, ?h binds at fire
  (role ?venue [k building pub] (select (score (near @self ?venue)) (policy roulette)))
  (when (and (> (attr @self appetite) 0.25)
             (>= (now-hour) (- ?h 1))
             (< (now-hour) (+ ?h 2))
             (> ?wealth 0.2)
             (= (believed-home-food-count ?home) 0)))
  (utility need (below eat))
  (effects       (begin-goal {@self eat [k supper] ?venue}))
  (cease-effects (end-goal   {@self eat [k supper] ?venue})))

(npc-think want_eat_out_restaurant
  ; upper-class only - the CACHED self-gate skips the majority (and the
  ; larder belief-fold below) with zero eval.
  (role @self {@self class_situation [k upper], wealth ?wealth})
  (role ?home {@self home ?home}
              {?home supper_hour ?h})   ; existence cached, ?h binds at fire
  (role ?venue [k building restaurant] (select (score (near @self ?venue)) (policy roulette)))
  (when (and (> (attr @self appetite) 0.25)
             (>= (now-hour) (- ?h 1))
             (< (now-hour) (+ ?h 2))
             (> ?wealth 0.2)
             (= (believed-home-food-count ?home) 0)))
  (utility need (below eat))
  (effects       (begin-goal {@self eat [k supper] ?venue}))
  (cease-effects (end-goal   {@self eat [k supper] ?venue})))

; ---- the shared approach: the <place> drives a leaf-first go sub-goal --------

; Not yet at the eat place -> head there via the generic enter chain (enter.hs),
; like worship. A MAINTENANCE rung (§5.11/§5.12): hold {@self enter ?place} while
; not at the place, cease it on arrival (at-place). The enter chain's sub-goals are
; the live leaves while routing; on arrival they collapse and the eat goal becomes
; the leaf and promotes to eat_act. ?place is bound from the eat goal (fixed, not
; rouletted). For breakfast / home-lunch / work-lunch the diner is already at the
; place, so eat_go is SELECTED but its (when) is false and mints nothing (never a
; spurious enter goal) - the eat goal promotes directly.
(npc-think eat_go
  (goal    {@self eat ?meal ?place})
  ; at-place, but BIND-FREE: (at-place)/(in-room) expand to (bind {@self location
  ; ?loc}) which hard-errors when holding_when_holds re-evaluates this maintenance
  ; (when) with the fire-time stash restored (?loc already bound). (believes {@self
  ; location ?place}) is the same "standing in ?place" test as an existence check.
  ; ?place is a BUILDING for every routine routing (home / pub / restaurant), or the
  ; gentry study ROOM - the OR covers both, in-building for the former, believes-
  ; location for the latter.
  (when    (not (or (spatial @self building ?place)
                    (spatial @self space ?place))))
  (effects (debug-print "TRACE-EATGO place=?place meal=?meal")
           (maintain-proposal {@self enter ?place})))

; A paid EATERY (pub / restaurant) - a supper bought out, as opposed to the free
; family table / workplace lunch. Keys the per-means intrinsics on eat_at_place.
(define-macro dining-out? (?p)
  (or (is-a ?p [k building pub]) (is-a ?p [k building restaurant])))

; TERMINAL step (act_body_purification): the meal is now PROPOSED, guarded by being AT its place.
; Because `eat` is a proposed label every {@self eat [k <meal>] <place>} desire drops out of the
; auction (it still persists + drives eat_go); the meal promotes ONLY here, ONLY once the diner is
; at the place - closing the "eat where there is no food" off-place fall-through. The proposal
; inherits the meal's own utility from the eat goal it /causes (via the (goal ...) gate).
;
; PER-MEANS intrinsics: a supper BOUGHT OUT differs from the free table not in the shared hunger
; it serves but in its own means-profile - it costs COIN, the sociable relish it (enthusiasm, the
; affiliative aspect of Extraversion), and a purse too light cannot buy it. The (cost ...) is the
; meal's ontological buy-price marked up by the venue ((price ?meal ?place) = the meal's cost scaled
; by the venue markup), run through (money-cost-util) to the felt utility of the actor's marginal value
; of money (dear to a pauper, nothing to a lord). Only a BOUGHT-OUT meal is charged; a home / workplace meal is eaten
; from one's own larder, so its cost + feasibility fold to nothing (the dining-out? gates below).
(npc-think eat_at_place
  (goal    {@self eat ?meal ?place})
  (when    (or (spatial @self building ?place)
               (spatial @self space ?place)))
  (effects (maintain-proposal {@self eat ?meal ?place}
             (affect   (if (dining-out? ?place) (then (* (attr @self enthusiasm) 20)) (else 0)))
             (cost     (money-cost-util (coin-balance @self)
                         (if (dining-out? ?place) (then (price ?meal ?place)) (else 0))))
             (feasible (or (not (dining-out? ?place)) (>= (coin-balance @self) (price ?meal ?place)))))))

; (PROVISIONING - the cook keeping the kitchen larder stocked - lives in
; npc-think/provisioning_think.hs; the general carry-to-a-place chain in
; npc-think/bring_think.hs. Meals only EAT here.)

; (EATING OUT is folded into the unified eat lane above: want_eat_out_pub /
; want_eat_out_restaurant mint {@self eat [k supper] <venue>}, eat_go walks
; there, and eat_act runs the meal - no venue prop consumed.)

; THE STARVATION TAIL (ruling 15) - past famished (appetite > 1.3) food-seeking
; overrides schedule and window. Every food-source lane carries the SAME convex
; (homeostatic appetite 2.0 70) drive: ~130 at the famished threshold (above every
; routine lane, work maxes at 100) and DIVERGING as appetite climbs toward the limit,
; so the closer to collapse the more decisively food-seeking dominates - the convex
; tail the old flat 130-141 band only approximated. The source PREFERENCE emerges, not
; from magic gaps: eat-at-source (carried / pantry, R=0) beats a go-leg (travel, -rhoR)
; automatically; forage_act's branch order picks among co-located sources; and buy vs
; steal never compete (mutually exclusive on the wealth guard). Venue knowledge rides
; the same provisions_shop belief the provisioning errand builds; a starving stranger
; to the town tries any shop.

; THE STARVING WATCH - the physiology->belief seam. Hunger is an ATTR (no belief
; seam, so no cached gate can key on it directly); this pair maintains the
; {@self starve} marker belief AT the crossing, so every tail lane below keys
; on the CACHED self-gate instead of re-reading the attr per deliberation. The
; watch itself is the only per-deliberation hunger read left (one attr read,
; gated to the not-yet-starving); the marker ends at the same threshold once
; a meal brings hunger back under. The tails keep the live hunger conjunct as
; the freshness check - it now only ever runs for the starving few.
(npc-think starving_watch
  (role @self -{@self starve})
  (when (> (attr @self appetite) 1.3))
  (effects
    (begin-belief {@self starve})))

(npc-think starving_watch_end
  (role @self {@self starve})
  (when (not (> (attr @self appetite) 1.3)))
  (effects
    (end-belief {@self starve})))

; The four food-source DESIRES all push the same convex drive onto one {@self forage}
; goal (the source is chosen by branch ORDER in forage_act, not by competing utility):
; eat what you carry > eat the pantry > buy at a shop > STEAL and eat. The GO lanes
; (already goal-based) route to home / a shop when not there.

; Eat what you carry: the laden cook (or laden thief) whose FIRST standing stow
; goal is a food item.
(npc-think starving_eat_carried
  (role @self {@self starve})
  (when (and (> (attr @self appetite) 1.3)
             (> (held-pile-count @self [k food]) 0)))
  (utility (starve-drive))
  (effects       (begin-goal {@self forage}))
  (cease-effects (end-goal   {@self forage})))

(npc-think starving_pantry
  (role @self {@self starve})
  (role ?home {@self home ?home})
  (when (and (> (attr @self appetite) 1.3)
             (at-home)
             (> (believed-home-food-count ?home) 0)))
  (utility (starve-drive))
  (effects       (begin-goal {@self forage}))
  (cease-effects (end-goal   {@self forage})))

(npc-think starving_go_home
  (role @self {@self starve})
  (role ?home {@self home ?home})
  (when (and (> (attr @self appetite) 1.3)
             (not (at-home))
             (> (believed-home-food-count ?home) 0)))
  (utility (starve-drive))
  (effects (maintain-proposal {@self enter ?home})))

; Buy: at a shop with wealth, one item eaten on the spot (paid-for in the v1
; no-coin sense as provisioning).
(npc-think starving_buy
  (role @self {@self starve ?, wealth ?wealth})
  (when (and (> (attr @self appetite) 1.3)
             (> ?wealth 0.2)
             (is-a (spatial @self building) [k building shop])))
  (utility (starve-drive))
  (effects       (begin-goal {@self forage}))
  (cease-effects (end-goal   {@self forage})))

(npc-think starving_buy_go
  (role @self {@self starve ?, wealth ?wealth})
  ; The known provisions_shop is preferred; else a role-cast shop the NPC KNOWS
  ; (nearest, weighted). Replaces the (venue ...) fallback.
  (role ?go_dest [k building shop] (select (score (near @self ?go_dest)) (policy roulette)))
  (any {@self provisions_shop ?shop})
  (when (and (> (attr @self appetite) 1.3)
             (> ?wealth 0.2)
             (not (is-a (spatial @self building) [k building shop]))))
  (utility (starve-drive))
  (effects
    (if ?shop
        (then (maintain-proposal {@self enter ?shop}))
        (else (maintain-proposal {@self enter ?go_dest})))))

; Steal: the pauper's act - at a shop with no wealth, the mouthful goes on the
; ledger (the shop owner is the victim). The row lands only when something was
; actually eaten - forage_act appends it inside its shop branch.
(npc-think starving_steal
  (role @self {@self starve ?, wealth ?wealth})
  (when (and (> (attr @self appetite) 1.3)
             (not (> ?wealth 0.2))
             (is-a (spatial @self building) [k building shop])))
  (utility (starve-drive))
  (effects       (begin-goal {@self forage}))
  (cease-effects (end-goal   {@self forage})))

(npc-think starving_steal_go
  (role @self {@self starve ?, wealth ?wealth})
  (role ?go_dest [k building shop] (select (score (near @self ?go_dest)) (policy roulette)))
  (any {@self provisions_shop ?shop})
  (when (and (> (attr @self appetite) 1.3)
             (not (> ?wealth 0.2))
             (not (is-a (spatial @self building) [k building shop]))))
  (utility (starve-drive))
  (effects
    (if ?shop
        (then (maintain-proposal {@self enter ?shop}))
        (else (maintain-proposal {@self enter ?go_dest})))))

; TERMINAL step: the {@self forage} goal, at a food source, promotes to the generic
; consume act. The four food-source desires above hold {@self forage} only while a
; source is reachable (carried / home pantry / shop); the promotion happens ONLY
; here. The readiness is the union of the arrived conditions the go rungs negate
; (carried anywhere / at home / at a shop). The SOURCE LADDER the old forage_act
; hardcoded is now the reasoning it belongs to - picked here by branch ORDER
; (carried > home pantry > shop) and handed to the act as ?item + ?owner. The
; proposal inherits the starving-band utility (141/140/135/130) from the
; {@self forage} goal it /causes (via the (goal ...) gate).
(npc-think forage_at_source
  (goal    {@self forage})
  (when    (or (> (held-pile-count @self [k food]) 0)
               (at-home)
               (is-a (spatial @self building) [k building shop])))
  ; Every food source is a PILE (basket / larder / shelf); ?item is bound to the
  ; pile and EAT eats one off its count (never destroys it). ?owner stays 0
  ; unless the mouthful is STOLEN (at a shop, no wealth) - then the shop owner is
  ; the wronged party the EAT act ledgers. An empty scene (?found 0 - a stale
  ; belief a sibling already ate) proposes nothing and lets the >1.3 gate re-drive.
  (effects
    (bind 0 ?found)
    (bind 0 ?owner)
    (bind 0 ?item)
    ; carried basket
    (bind 0 ?carried_pile)
    (held-pile-into @self [k food] ?carried_pile)
    (if (and (= ?found 0) ?carried_pile (> (attr ?carried_pile count) 0))
        (then (bind ?carried_pile ?item) (bind 1 ?found)))
    ; home larder (the kitchen pile - the diner stands in the home)
    (if (and (= ?found 0) (at-home))
        (then
          (bind 0 ?home_kitchen)
          (spatial (any {@self home}).target room [k kitchen]): ?home_kitchen
          (if ?home_kitchen
              (then
                (bind 0 ?larder_pile)
                (pile-at-into ?home_kitchen [k food] ?larder_pile)
                (if (and ?larder_pile (> (attr ?larder_pile count) 0))
                    (then (bind ?larder_pile ?item) (bind 1 ?found)))))))
    ; shop shelf
    (if (and (= ?found 0)
             (is-a (spatial @self building) [k building shop])
             (spatial @self building))
        (then
          (spatial @self building): ?shop
          (for-each ?room (spatial ?shop parts [k interior_space room] /env)
            (do
              (bind 0 ?shelf_pile)
              (pile-at-into ?room [k food] ?shelf_pile)
              (if (and (= ?found 0) ?shelf_pile (> (attr ?shelf_pile count) 0))
                  (then (bind ?shelf_pile ?item)
                        (bind 1 ?found)
                        (begin-belief {@self provisions_shop ?shop})
                        (if (not (> (any {@self wealth}).target 0.2))
                            (then (owner-of ?shop): ?owner))))))))
    (if (= ?found 1)
        (then (maintain-proposal {@self EAT ?item ?owner})))))

; ---- the eat TASK's PERFORMANCE rungs ----------------------------------------
; eat is a TASK (Tasks.mon): its desires promote it AT the place (eat_at_place),
; and these rungs PERFORM it. The physical eating is the EAT action (duration +
; hunger); the food to consume is the REASONING
; (which loaf, is it a home supper) decided HERE and handed to EAT on its
; pattern. The task self-limits: EAT relieves hunger, the desire's window /
; appetite gate ceases the eat goal, eat_at_place withdraws its maintainer, the
; running task retires. table_talk (its own rule) is the third rung.

; TAKE THE MEAL: pick the food, propose EAT. Only a home supper consumes a
; PERSON-DAY food prop (?food = a believed loaf); breakfast / lunch / a bought-out
; supper eat abstractly (?food = 0, EAT destroys nothing). A stale belief (a loaf
; a sibling already ate) reads @fail (falsy) and the supper stays abstract.
; The eat TASK (take_meal / table_hours / table_talk) lives in npc-tasks/eat-task.hs.
