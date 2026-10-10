; ----------------------------------------------------------------------------
; meals - the drivers of the UNIFIED eat aspect: the meal desires, the at-home idle yield,
; and the starvation-tail desires.
;
; ONE task serves every routine meal: {@self eat [k <meal>] <place>} (tasks/eat-task.mc) - a
; desire proposes it in its window, and the task walks to the <place> and eats there.
;
; UTILITY IS PROXIMITY TO THE MEALTIME, NEVER HUNGER (ruling 10): each desire is
; eligible only inside its believed window. Hunger is pure physiology - it
; accrues at the completion seam (sleep included - you wake hungry) and each
; meal reduces it - and enters the aspect only as the ELIGIBILITY gate
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
;                shade over the work aspect so the commuter eats before leaving.
;   lunch      - one meal-kind, two places: at the workplace at midday (util 85,
;                the co-worker channel) OR at home per lunch-hour (util 76).
;   supper     - the FAMILY table, 60 min. Utility 78: under work's 80, over
;                leisure. The window opens an hour early so eat-go's travel
;                (30 min) lands the household home by the cook's hour. When the
;                diner KNOWS of no food at home + wealth permits, EATING OUT
;                mints the same supper goal at a pub / restaurant instead
;                (util 70) - the venue kitchen is abstract (no prop consumed).
; ----------------------------------------------------------------------------

; ------------------------------------------------------- the mealtime yield

; idle-at-home - the at-home nothing-to-do slot, a DWELL in blocks, one per canonical meal
; window, each aimed at its ABSOLUTE boundary hour. Intra-day eligibility is only sampled at
; act completions, so an uncapped multi-hour idle would leap clean over a meal window; ending
; each block at the next meal boundary gives the meal drivers their deliberation instant (a
; household's own +-1h mealtime shift just moves who wins the boundary). Each (hours ..) rung
; ends its bout at its boundary, so a resumed dwell never carries a stale ?until across
; windows; post-supper the block runs to midnight and the sleep aspect takes over long before.
(driver idle-at-home
  (role ?home {@self home ?home}
              (spatial @self unit ?home)
    (declare-utility idle fallback)
    (stable-or
      (try
        (when (hours 0 12))
        (effects (maintain-proposal {@self DWELL ?home 12})))
      (try
        (when (hours 12 18))
        (effects (maintain-proposal {@self DWELL ?home 18})))
      (try
        (when (hours 18 0))
        (effects (maintain-proposal {@self DWELL ?home 24}))))))

; ============================ the unified eat aspect ==========================
; Every routine meal is ONE task {@self eat [k <meal>] <place>}: a desire proposes it in its
; window, and the task walks to the <place> and eats there. The ended act-belief IS the meal
; memory (target = the meal occasion, aux = the place); there is no separate dine record.

(include "../../../macros/intensity-macros.mc")
(include "../../../macros/collection-macros.mc")
(include "../../../macros/money-macros.mc")

; THE STARVATION DRIVE - the banded escalation ladder for hunger past its window.
; The starving tail (below) all gate on appetite > 1.3, so this always sits in the
; CRISIS band (starving is an acute emergency, above every routine need); the ladder
; keeps the sub-need shape for any future re-gating. Value climbs convex toward collapse.
; (define-macro starve-drive ()
;   (homeostatic-banded appetite 2.0
;     [/want   0.0  0   500]
;     [/need   0.45 300 900]
;     [/crisis 0.9  600 1000]))

; ---- notice the larder -----------------------------------------------------
; A home, hungry resident who believes there is NO food OBSERVES their own
; kitchen (the larder room), surfacing its contents into belief. Without this
; only the cook - who stocks and frequents the kitchen - knows the food is there;
; the rest of the family believes an empty larder, skips the family table, and
; starves beside a full kitchen. Per-mind honest (you check your own kitchen when
; hungry at home) and un-gated by food belief (LEARNING whether food is there is
; the whole point). Self-limiting: once the food is seen the count is > 0 and this
; stops firing until the larder is eaten down again; a truly empty kitchen keeps
; reading 0 and the resident falls through to the meal-less chains, as it should.
(think notice-larder
  (role @self {@self satiety [k hungry|famished]}
    (role ?home {@self home ?home}
                (spatial @self unit ?home)
                (spatial ?home room [k kitchen]): ?kitchen   ; a resident who does not know their kitchen just skips
      (when (= (believed-home-food-count ?home) 0))
      (effects
        (observe ?kitchen)))))

; ---- the meal desires (propose {@self eat [k <meal>] <place>}) -------------

; A hungry man wants his meal as a need, a famished one as a crisis.
(define-macro meal-utility-band () (if (any {@self satiety [k famished]}) (then crisis) (else need)))

; BREAKFAST - at home, come-as-you-wake (3h window, the one exception to the 2h
; rule): you breakfast in the house you woke in or not at all.
(define-macro breakfast-window-hours () 3)
(define-macro meal-window-hours ()      2)
(define-macro supper-lead-hours ()      1)

(driver want-breakfast
  (role @self {@self satiety [k hungry|famished]}
    (role ?home {@self home ?home}
                {?home breakfast-hour ?}
                (spatial @self unit ?home)
      (when (hours (household-breakfast-hour) (+ (household-breakfast-hour) (breakfast-window-hours))) (> (believed-home-food-count ?home) 0))
      (declare-utility (meal-utility-band) default)
      (effects
        (maintain-proposal {@self eat [k breakfast] ?home}
          [/affect (meal-affect ?home)]
          [/cost (meal-cost [k breakfast] ?home)]
          [/feasible (eat-affordable [k breakfast] ?home)])))))

; LUNCH at the workplace - the CO-WORKER channel (eat where you stand at midday).
(driver want-lunch-work
  (role @self {@self satiety [k hungry|famished]}
    (role ?job {@self job ?job}
      (role ?org {?job org ?org}           ; produced-restricted: ?org threaded off ?job
                 {?org workplace ?wp}       ; ?wp binds at fire
                 (spatial @self building ?wp)                    ; residual gate, re-checked at the when-seam
        (when (hours 12 14))
        (declare-utility (meal-utility-band) default)
        (effects
          (maintain-proposal {@self eat [k lunch] ?wp}
            [/affect (meal-affect ?wp)]
            [/cost (meal-cost [k lunch] ?wp)]
            [/feasible (eat-affordable [k lunch] ?wp)]))))))

; LUNCH at home - the jobless / housewife / child midday meal, per lunch-hour.
(driver want-lunch-home
  (role @self {@self satiety [k hungry|famished]}
    (role ?home {@self home ?home}
                {?home lunch-hour ?}
                (spatial @self unit ?home)
      (when (hours (household-lunch-hour) (+ (household-lunch-hour) (meal-window-hours))) (> (believed-home-food-count ?home) 0))
      (declare-utility (meal-utility-band) default)
      (effects
        (maintain-proposal {@self eat [k lunch] ?home}
          [/affect (meal-affect ?home)]
          [/cost (meal-cost [k lunch] ?home)]
          [/feasible (eat-affordable [k lunch] ?home)])))))

; SUPPER at home - the FAMILY table. The window opens an hour early so eat-go's
; travel (30 min) lands the household home by the cook's hour.
(driver want-supper
  (role @self {@self satiety [k hungry|famished]}
    (role ?home {@self home ?home}
                {?home supper-hour ?}
      (when (hours (- (household-supper-hour) (supper-lead-hours)) (+ (household-supper-hour) (meal-window-hours))) (> (believed-home-food-count ?home) 0))
      (declare-utility (meal-utility-band) default)
      (effects
        (maintain-proposal {@self eat [k supper] ?home}
          [/affect (meal-affect ?home)]
          [/cost (meal-cost [k supper] ?home)]
          [/feasible (eat-affordable [k supper] ?home)])))))

(define-func eat-dining-out (?place)
  (tolerate (or (is-a ?place [k pub-building]) (is-a ?place [k restaurant-building]))): ?dining-out
  ?dining-out)

(define-func eat-affordable (?meal ?place)
  (any {@self carrying-cash.count ?coins=0}): ?cash
  (or (not (eat-dining-out ?place)) (>= ?coins (price ?meal ?place))): ?affordable
  ?affordable)

; PER-MEANS intrinsics: a supper BOUGHT OUT differs from the free table not in the hunger it
; serves but in its own means-profile - it costs COIN, the sociable relish it (enthusiasm, the
; affiliative aspect of Extraversion), and a purse too light cannot buy it (eat-affordable).
; The cost is the meal's buy-price marked up by the venue ((price ?meal ?place)) through
; (money-cost-util) to the felt utility of the diner's marginal value of money. Only a
; BOUGHT-OUT meal is charged; a home / workplace meal is eaten from one's own larder.
(define-func meal-affect (?place)
  (any {@self enthusiasm ?enthusiasm=0.0})
  (if (eat-dining-out ?place) (then (* ?enthusiasm 20.0)) (else 0.0)))

(define-func meal-cost (?meal ?place)
  (any {@self carrying-cash.count ?coins=0})
  (money-cost-util ?coins (if (eat-dining-out ?place) (then (price ?meal ?place)) (else 0))))

; At the meal's place: in its building, or in its room for a meal taken in one.
(define-func at-meal-place (?place)
  (or (spatial @self building ?place) (spatial @self space ?place)))

; EATING OUT - no food at home (as the diner KNOWS) in the supper window and
; the cash he carries pays for it: a pub supper (lower/middle), a restaurant one (upper). The
; venue is the eat place; eat-go walks there. It never competes with the home
; supper, whose stock gate is this one's negation.
(driver want-eat-out-pub
  ; class gate = CACHED self-gate filter (the belief form, not the live conjunct).
  (role @self {@self satiety [k hungry|famished]}
              -{@self class-situation [k upper]}
    (role ?home {@self home ?home}
                {?home supper-hour ?}
      (role ?venue [k pub-building] (select (score (near @self ?venue)) (policy roulette unknown-last))
        (when (hours (- (household-supper-hour) (supper-lead-hours)) (+ (household-supper-hour) (meal-window-hours))) (and (eat-affordable [k supper] ?venue)
                   (= (believed-home-food-count ?home) 0)))
        (declare-utility (meal-utility-band) default)
        (effects
          (maintain-proposal {@self eat [k supper] ?venue}
            [/affect (meal-affect ?venue)]
            [/cost (meal-cost [k supper] ?venue)]
            [/feasible (eat-affordable [k supper] ?venue)]))))))

(driver want-eat-out-restaurant
  ; upper-class only - the CACHED self-gate skips the majority (and the
  ; larder belief-fold below) with zero eval.
  (role @self {@self satiety [k hungry|famished]}
              {@self class-situation [k upper]}
    (role ?home {@self home ?home}
                {?home supper-hour ?}
      (role ?venue [k restaurant-building] (select (score (near @self ?venue)) (policy roulette unknown-last))
        (when (hours (- (household-supper-hour) (supper-lead-hours)) (+ (household-supper-hour) (meal-window-hours))) (and (eat-affordable [k supper] ?venue)
                   (= (believed-home-food-count ?home) 0)))
        (declare-utility (meal-utility-band) default)
        (effects
          (maintain-proposal {@self eat [k supper] ?venue}
            [/affect (meal-affect ?venue)]
            [/cost (meal-cost [k supper] ?venue)]
            [/feasible (eat-affordable [k supper] ?venue)]))))))

; (PROVISIONING - the cook keeping the kitchen larder stocked - lives in
; thinks/provisioning_think.mc; the general carry-to-a-place chain in
; thinks/bring_think.mc. Meals only EAT here.)

; (EATING OUT is folded into the unified eat aspect above: want-eat-out-pub /
; want-eat-out-restaurant propose {@self eat [k supper] <venue>}, and the eat task walks
; there and runs the meal - no venue prop consumed.)

; THE STARVATION TAIL (ruling 15) - past famished (appetite > 1.3) food-seeking
; overrides schedule and window. Every food-source chain carries the SAME convex
; (homeostatic appetite 2.0 70) drive: ~130 at the famished threshold (above every
; routine aspect, work maxes at 100) and DIVERGING as appetite climbs toward the limit,
; so the closer to collapse the more decisively food-seeking dominates - the convex
; tail the old flat 130-141 band only approximated. The source PREFERENCE emerges, not
; from magic gaps: eat-at-source (carried / pantry, R=0) beats a go-leg (travel, -rhoR)
; automatically; forage_act's branch order picks among co-located sources; and buy vs
; steal never compete (mutually exclusive on the wealth guard). Venue knowledge rides
; the same provisions-shop belief the provisioning errand builds; a starving stranger
; to the town tries any shop.

; DISABLED, down to forage_at_source: no mind eats (the eat task and forage never run), so
; every mind starves from day one and these drivers swamp every other aspect.
; THE STARVING WATCH - the physiology->belief seam. Hunger is an ATTR (no belief
; seam, so no cached gate can key on it directly); this pair maintains the
; {@self starve} marker belief AT the crossing, so every tail chain below keys
; on the CACHED self-gate instead of re-reading the attr per deliberation. The
; watch itself is the only per-deliberation hunger read left (one attr read,
; gated to the not-yet-starving); the marker ends at the same threshold once
; a meal brings hunger back under. The tails keep the live hunger conjunct as
; the freshness check - it now only ever runs for the starving few.
; (think starving_watch
;   (role @self -{@self starve}
;     (when (> (any {@self appetite ?=0.0}).target 1.3))
;     (effects
;       (begin-belief {@self starve}))))

; (think starving_watch_end
;   (role @self {@self starve}
;     (when (not (> (any {@self appetite ?=0.0}).target 1.3)))
;     (effects
;       (end-belief {@self starve}))))

; The four food-source DESIRES all push the same convex drive onto one {@self forage}
; goal (the source is chosen by branch ORDER in forage_act, not by competing utility):
; eat what you carry > eat the pantry > buy at a shop > STEAL and eat. The GO chains
; (already goal-based) route to home / a shop when not there.

; Eat what you carry: the laden cook (or laden thief) whose FIRST standing stow
; goal is a food item.
; (think starving_eat_carried
;   (role @self {@self starve}
;     (when (and (> (any {@self appetite ?=0.0}).target 1.3)
;                (> (held-pile-count @self [k food]) 0)))
;     (declare-utility (starve-drive))
;     (effects       (begin-goal {@self forage}))
;     (when-unsupported-effects (set-outcome {@self goal {@self forage}} /succ))))

; (think starving_pantry
;   (role @self {@self starve}
;     (role ?home {@self home ?home}
;                 (spatial @self unit ?home)
;       (when (and (> (any {@self appetite ?=0.0}).target 1.3)
;                  (> (believed-home-food-count ?home) 0)))
;       (declare-utility (starve-drive))
;       (effects       (begin-goal {@self forage}))
;       (when-unsupported-effects (set-outcome {@self goal {@self forage}} /succ)))))

; (think starving_go_home
;   (role @self {@self starve}
;     (role ?home {@self home ?home}
;                 (not (spatial @self unit ?home))
;       (when (and (> (any {@self appetite ?=0.0}).target 1.3)
;                  (> (believed-home-food-count ?home) 0)))
;       (declare-utility (starve-drive))
;       (effects (maintain-proposal {@self go ?home})))))

; Buy: at a shop with wealth, one item eaten on the spot (paid-for in the v1
; no-coin sense as provisioning).
; (think starving_buy
;   (role @self {@self starve ?, wealth ?wealth}
;     (when (and (> (any {@self appetite ?=0.0}).target 1.3)
;                (> ?wealth 0.2)
;                (is-a (spatial @self building) [k shop])))
;     (declare-utility (starve-drive))
;     (effects       (begin-goal {@self forage}))
;     (when-unsupported-effects (set-outcome {@self goal {@self forage}} /succ))))

; (think starving_buy_go
;   (role @self {@self starve ?, wealth ?wealth}
;     (when (and (> (any {@self appetite ?=0.0}).target 1.3)
;                (> ?wealth 0.2)
;                (not (is-a (spatial @self building) [k shop]))))
;     (declare-utility (starve-drive))
;     ; THE PREFERENCE IS THE RUNG ORDER: the shop he knows sells provisions, else any shop he
;     ; knows at all, nearest-weighted.
;     (stable-or
;       (try
;         (role ?shop {@self provisions-shop ?shop} (select (policy first-match))
;           (effects (maintain-proposal {@self go ?shop}))))
;       (try
;         (role ?go_dest [k shop] (select (score (near @self ?go_dest)) (policy roulette))
;           (effects (maintain-proposal {@self go ?go_dest})))))))

; Steal: the pauper's act - at a shop with no wealth, the mouthful goes on the
; ledger (the shop owner is the victim). The row lands only when something was
; actually eaten - forage_act appends it inside its shop branch.
; (think starving_steal
;   (role @self {@self starve ?, wealth ?wealth}
;     (when (and (> (any {@self appetite ?=0.0}).target 1.3)
;                (not (> ?wealth 0.2))
;                (is-a (spatial @self building) [k shop])))
;     (declare-utility (starve-drive))
;     (effects       (begin-goal {@self forage}))
;     (when-unsupported-effects (set-outcome {@self goal {@self forage}} /succ))))

; (think starving_steal_go
;   (role @self {@self starve ?, wealth ?wealth}
;     (when (and (> (any {@self appetite ?=0.0}).target 1.3)
;                (not (> ?wealth 0.2))
;                (not (is-a (spatial @self building) [k shop]))))
;     (declare-utility (starve-drive))
;     ; THE PREFERENCE IS THE RUNG ORDER, as in starving_buy_go above.
;     (stable-or
;       (try
;         (role ?shop {@self provisions-shop ?shop} (select (policy first-match))
;           (effects (maintain-proposal {@self go ?shop}))))
;       (try
;         (role ?go_dest [k shop] (select (score (near @self ?go_dest)) (policy roulette))
;           (effects (maintain-proposal {@self go ?go_dest})))))))

; TERMINAL step: the {@self forage} goal, at a food source, promotes to the generic
; consume act. The four food-source desires above hold {@self forage} only while a
; source is reachable (carried / home pantry / shop); the promotion happens ONLY
; here. The readiness is the union of the arrived conditions the go rungs negate
; (carried anywhere / at home / at a shop). The SOURCE LADDER the old forage_act
; hardcoded is now the reasoning it belongs to - picked here by branch ORDER
; (carried > home pantry > shop) and handed to the act as ?item + ?owner. The
; proposal inherits the starving-band utility (141/140/135/130) from the
; {@self forage} goal it /causes (via the (goal ...) gate).
; (think forage_at_source
;   (goal    {@self forage})
;   (when    (or (> (held-pile-count @self [k food]) 0)
;                (at-home)
;                (is-a (spatial @self building) [k shop])))
;   ; Every food source is a PILE (basket / larder / shelf); ?item is bound to the
;   ; pile and EAT eats one off its count (never destroys it). ?owner stays 0
;   ; unless the mouthful is STOLEN (at a shop, no wealth) - then the shop owner is
;   ; the wronged party the EAT act ledgers. An empty scene (?found 0 - a stale
;   ; belief a sibling already ate) proposes nothing and lets the >1.3 gate re-drive.
;   (effects
;     (bind 0 ?found)
;     (bind 0 ?owner)
;     (bind 0 ?item)
;     ; carried basket
;     (bind 0 ?carried_pile)
;     (held-pile-into @self [k food] ?carried_pile)
;     (if (and (= ?found 0) ?carried_pile (> (attr ?carried_pile count) 0))
;         (then (bind ?carried_pile ?item) (bind 1 ?found)))
;     ; home larder (the kitchen pile - the diner stands in the home)
;     (if (and (= ?found 0) (at-home))
;         (then
;           (bind 0 ?home_kitchen)
;           (spatial (any {@self home}).target room [k kitchen]): ?home_kitchen
;           (if ?home_kitchen
;               (then
;                 (bind 0 ?larder_pile)
;                 (pile-at-into ?home_kitchen [k food] ?larder_pile)
;                 (if (and ?larder_pile (> (attr ?larder_pile count) 0))
;                     (then (bind ?larder_pile ?item) (bind 1 ?found)))))))
;     ; shop shelf
;     (spatial @self building): ?shop
;     (if (and (= ?found 0) ?shop (is-a ?shop [k shop]))
;         (then
;           (for-each ?room (spatial ?shop rooms /env)
;             (do
;               (bind 0 ?shelf_pile)
;               (pile-at-into ?room [k food] ?shelf_pile)
;               (if (and (= ?found 0) ?shelf_pile (> (attr ?shelf_pile count) 0))
;                   (then (bind ?shelf_pile ?item)
;                         (bind 1 ?found)
;                         (begin-belief {@self provisions-shop ?shop})
;                         (if (not (> (any {@self wealth}).target 0.2))
;                             (then (any {? own ?shop}).subject: ?owner))))))))
;     (if (= ?found 1)
;         (then (maintain-proposal {@self EAT ?item ?owner})))))

; ---- the eat TASK's PERFORMANCE rungs ----------------------------------------
; eat is a TASK (tasks.mon): its desires promote it AT the place (eat-at-place),
; and these rungs PERFORM it. The physical eating is the EAT action (duration +
; hunger); the food to consume is the REASONING
; (which loaf, is it a home supper) decided HERE and handed to EAT on its
; pattern. The task self-limits: EAT relieves hunger, the desire's window /
; satiety band ceases the eat goal, eat-at-place withdraws its maintainer, the
; running task retires. table_talk (its own rule) is the third rung.

; TAKE THE MEAL: pick the food, propose EAT. Only a home supper consumes a
; PERSON-DAY food prop (?food = a believed loaf); breakfast / lunch / a bought-out
; supper eat abstractly (?food = 0, EAT destroys nothing). A stale belief (a loaf
; a sibling already ate) reads @fail (falsy) and the supper stays abstract.
; The eat TASK (take_meal / table_hours / table_talk) lives in tasks/eat-task.mc.
