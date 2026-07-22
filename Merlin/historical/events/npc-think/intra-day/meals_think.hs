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
; the asker's OWN whereabouts beliefs via (count-believed-located [k food]
; <place>) - what this NPC has actually SEEN lying about the house - and the
; supper consume acts on a specific believed item. Keep the count op LAST in
; each (when) so the belief fold only runs on otherwise-eligible NPCs.
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
  (schedule always)
  (role ?home (believes {@self home ?home}))
  (when (at-home))
  (utility 2)
  (effects       (begin-goal {@self dwell ?home}))
  (cease-effects (end-goal   {@self dwell ?home})))

; TERMINAL step (act_body_purification): the at-home dwell is now PROPOSED, guarded by being at
; home, not auto-promoted by the bare {@self dwell ?home} goal. idle_at_home holds the goal (util
; 2, the at-home nothing-to-do slot); the dwell promotes ONLY here, ONLY at home. The proposal
; inherits the idle utility from the {@self dwell ?home} goal it /causes (via the (goal ...) gate).
(npc-think dwell_at_home
  (schedule always)
  (goal    {@self dwell ?home})
  (when    (at-home))
  (effects (propose {@self dwell ?home})))

; ============================ the unified eat lane ==========================
; Every routine meal is ONE act-goal {@self eat [k <meal>] <place>}: a desire
; mints it in its window, the <place> drives a leaf-first approach (eat_go), and
; at the place the goal promotes to the shared eat_act. The begun-then-ended
; act-belief IS the meal memory (target = the meal occasion, aux = the place);
; there is no separate dine record.

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
  (schedule always)
  (role ?home (believes {@self home ?home}))
  (when (and (at-home)
             (> (attr @self appetite) 0.25)
             (= (count-believed-located [k food] ?home) 0)
             (bind {?home room [k kitchen]:?kitchen})))   ; a resident who does not know their kitchen just skips
  (effects
    (observe ?kitchen)))

; ---- the meal desires (mint {@self eat [k <meal>] <place>}) ----------------

; BREAKFAST - at home, come-as-you-wake (3h window, the one exception to the 2h
; rule): you breakfast in the house you woke in or not at all.
(npc-think want_breakfast
  (schedule always)
  (role ?home (believes {@self home ?home})
              (believes {?home breakfast_hour ?h}))   ; existence cached, ?h binds at fire
  (when (and (at-home)
             (> (attr @self appetite) 0.25)
             (>= (now-hour) ?h)
             (< (now-hour) (+ ?h 3))
             (> (count-believed-located [k food] ?home) 0)))
  (utility 82)
  (effects       (begin-goal {@self eat [k breakfast] ?home}))
  (cease-effects (end-goal   {@self eat [k breakfast] ?home})))

; LUNCH at the workplace - the CO-WORKER channel (eat where you stand at midday).
(npc-think want_lunch_work
  (schedule always)
  (role ?org (believes {@self employer ?org})
             (believes {?org workplace ?wp}))   ; ?wp binds at fire
  (when (and (> (attr @self appetite) 0.25)
             (at-workplace ?wp)
             (>= (now-hour) 12)
             (< (now-hour) 14)))
  (utility 85)
  (effects       (begin-goal {@self eat [k lunch] ?wp}))
  (cease-effects (end-goal   {@self eat [k lunch] ?wp})))

; LUNCH at home - the jobless / housewife / child midday meal, per lunch_hour.
(npc-think want_lunch_home
  (schedule always)
  (role ?home (believes {@self home ?home})
              (believes {?home lunch_hour ?h}))   ; existence cached, ?h binds at fire
  (when (and (at-home)
             (> (attr @self appetite) 0.25)
             (>= (now-hour) ?h)
             (< (now-hour) (+ ?h 2))
             (> (count-believed-located [k food] ?home) 0)))
  (utility 76)
  (effects       (begin-goal {@self eat [k lunch] ?home}))
  (cease-effects (end-goal   {@self eat [k lunch] ?home})))

; SUPPER at home - the FAMILY table. The window opens an hour early so eat_go's
; travel (30 min) lands the household home by the cook's hour.
(npc-think want_supper
  (schedule always)
  (role ?home (believes {@self home ?home})
              (believes {?home supper_hour ?h}))   ; existence cached, ?h binds at fire
  (when (and (> (attr @self appetite) 0.25)
             (>= (now-hour) (- ?h 1))
             (< (now-hour) (+ ?h 2))
             (> (count-believed-located [k food] ?home) 0)))
  (utility 78)
  (effects       (begin-goal {@self eat [k supper] ?home}))
  (cease-effects (end-goal   {@self eat [k supper] ?home})))

; EATING OUT - no food at home (as the diner KNOWS) in the supper window and
; wealth permits: a pub supper (lower/middle), a restaurant one (upper). The
; venue is the eat place; eat_go walks there. Utility 70: under the home supper
; (whose stock gate already failed if this is eligible), over leisure.
(npc-think want_eat_out_pub
  (schedule always)
  ; class gate = CACHED self-gate filter (the belief form, not the live conjunct).
  (role @self (not (believes {@self class_situation [k upper]})))
  (role ?home (believes {@self home ?home})
              (believes {?home supper_hour ?h}))   ; existence cached, ?h binds at fire
  (role ?venue [k building pub] (select (score (near @self ?venue)) (policy roulette)))
  (when (and (> (attr @self appetite) 0.25)
             (>= (now-hour) (- ?h 1))
             (< (now-hour) (+ ?h 2))
             (> (target {@self wealth}) 0.2)
             (= (count-believed-located [k food] ?home) 0)))
  (utility 70)
  (effects       (begin-goal {@self eat [k supper] ?venue}))
  (cease-effects (end-goal   {@self eat [k supper] ?venue})))

(npc-think want_eat_out_restaurant
  (schedule always)
  ; upper-class only - the CACHED self-gate skips the majority (and the
  ; larder belief-fold below) with zero eval.
  (role @self (believes {@self class_situation [k upper]}))
  (role ?home (believes {@self home ?home})
              (believes {?home supper_hour ?h}))   ; existence cached, ?h binds at fire
  (role ?venue [k building restaurant] (select (score (near @self ?venue)) (policy roulette)))
  (when (and (> (attr @self appetite) 0.25)
             (>= (now-hour) (- ?h 1))
             (< (now-hour) (+ ?h 2))
             (> (target {@self wealth}) 0.2)
             (= (count-believed-located [k food] ?home) 0)))
  (utility 70)
  (effects       (begin-goal {@self eat [k supper] ?venue}))
  (cease-effects (end-goal   {@self eat [k supper] ?venue})))

; ---- the shared approach: the <place> drives a leaf-first go sub-goal --------

; Not yet at the eat place -> head there via the generic enter chain (enter.hs),
; like worship. A MAINTENANCE rung (§5.11/§5.12): hold {@self enter ?place} while
; not at the place, cease it on arrival (at-place). The enter chain's sub-goals are
; the live leaves while routing; on arrival they collapse and the eat goal becomes
; the leaf and promotes to eat_act. ?place is bound from the eat goal (fixed, not
; rouletted). For breakfast / home-lunch / work-lunch the diner is already at the
; place, so eat_go is SELECTED but its (when) is false, mints nothing, and stays
; re-schedulable (never a spurious enter goal) - the eat goal promotes directly.
(npc-think eat_go
  (schedule on-commit)
  (if-blocked hold)
  (goal    {@self eat ?meal ?place})
  ; at-place, but BIND-FREE: (at-place)/(in-room) expand to (bind {@self location
  ; ?loc}) which hard-errors when holding_when_holds re-evaluates this maintenance
  ; (when) with the fire-time stash restored (?loc already bound). (believes {@self
  ; location ?place}) is the same "standing in ?place" test as an existence check.
  ; ?place is a BUILDING for every routine routing (home / pub / restaurant), or the
  ; gentry study ROOM - the OR covers both, in-building for the former, believes-
  ; location for the latter.
  (when    (not (or (in-building ?place)
                    (believes {@self location ?place}))))
  (effects       (begin-goal {@self enter ?place}))
  (cease-effects (end-goal   {@self enter ?place})))

; TERMINAL step (act_body_purification): the meal is now PROPOSED, guarded by being AT its place.
; Because `eat` is a proposed label every {@self eat [k <meal>] <place>} desire drops out of the
; auction (it still persists + drives eat_go); the meal promotes ONLY here, ONLY once the diner is
; at the place - closing the "eat where there is no food" off-place fall-through. The proposal
; inherits the meal's own utility from the eat goal it /causes (via the (goal ...) gate).
(npc-think eat_at_place
  (schedule always)
  (goal    {@self eat ?meal ?place})
  (when    (or (in-building ?place)
               (believes {@self location ?place})))
  (effects (propose {@self eat ?meal ?place})))

; (PROVISIONING - the cook keeping the kitchen larder stocked - lives in
; npc-think/provisioning_think.hs; the general carry-to-a-place chain in
; npc-think/bring_think.hs. Meals only EAT here.)

; (EATING OUT is folded into the unified eat lane above: want_eat_out_pub /
; want_eat_out_restaurant mint {@self eat [k supper] <venue>}, eat_go walks
; there, and eat_act runs the meal - no venue prop consumed.)

; THE STARVATION TAIL (ruling 15) - past famished (hunger > 1.3) food-seeking
; overrides schedule and window. Utility band 130-141: above every routine
; lane (work maxes at 100), below the fight lane (150-200) - a starving man
; still defends himself first (and under-attack gates these out anyway).
; Ladder inside the band: eat what you carry (141) > eat the pantry (140) >
; go home to a stocked pantry (138) > buy at a shop if wealth permits (135)
; > STEAL food and eat it (130) - the pauper's arc: a real ledger crime.
; Venue knowledge rides the same provisions_shop belief the provisioning
; errand builds; a starving stranger to the town tries any shop.

; THE STARVING WATCH - the physiology->belief seam. Hunger is an ATTR (no belief
; seam, so no cached gate can key on it directly); this pair maintains the
; {@self starving} marker belief AT the crossing, so every tail lane below keys
; on the CACHED self-gate instead of re-reading the attr per deliberation. The
; watch itself is the only per-deliberation hunger read left (one attr read,
; gated to the not-yet-starving); the marker ends at the same threshold once
; a meal brings hunger back under. The tails keep the live hunger conjunct as
; the freshness check - it now only ever runs for the starving few.
(npc-think starving_watch
  (schedule always)
  (role @self (not (believes {@self starving})))
  (when (> (attr @self appetite) 1.3))
  (effects
    (begin-belief {@self starving})))

(npc-think starving_watch_end
  (schedule always)
  (role @self (believes {@self starving}))
  (when (not (> (attr @self appetite) 1.3)))
  (effects
    (end-belief {@self starving})))

; The four food-source DESIRES all push utility onto one {@self forage} goal (the
; ladder is by branch ORDER in forage_act, not by competing goals): eat what you
; carry (141) > eat the pantry (140) > buy at a shop (135) > STEAL and eat (130).
; The GO lanes (already goal-based) route to home / a shop when not there.

; Eat what you carry: the laden cook (or laden thief) whose FIRST standing stow
; goal is a food item.
(npc-think starving_eat_carried
  (schedule on-commit)
  (if-blocked hold)
  (role @self (believes {@self starving}))
  (when (and (> (attr @self appetite) 1.3)
             (control [k food])))
  (utility 141)
  (effects       (begin-goal {@self forage}))
  (cease-effects (end-goal   {@self forage})))

(npc-think starving_pantry
  (schedule on-commit)
  (if-blocked hold)
  (role @self (believes {@self starving}))
  (role ?home (believes {@self home ?home}))
  (when (and (> (attr @self appetite) 1.3)
             (at-home)
             (> (count-believed-located [k food] ?home) 0)))
  (utility 140)
  (effects       (begin-goal {@self forage}))
  (cease-effects (end-goal   {@self forage})))

(npc-think starving_go_home
  (schedule on-commit)
  (if-blocked hold)
  (role @self (believes {@self starving}))
  (role ?home (believes {@self home ?home}))
  (when (and (> (attr @self appetite) 1.3)
             (not (at-home))
             (> (count-believed-located [k food] ?home) 0)))
  (utility 138)
  (effects       (begin-goal {@self enter ?home}))
  (cease-effects (end-goal   {@self enter ?home})))

; Buy: at a shop with wealth, one item eaten on the spot (paid-for in the v1
; no-coin sense as provisioning).
(npc-think starving_buy
  (schedule on-commit)
  (if-blocked hold)
  (role @self (believes {@self starving}))
  (when (and (> (attr @self appetite) 1.3)
             (> (target {@self wealth}) 0.2)
             (at-place-kind [k building shop])))
  (utility 135)
  (effects       (begin-goal {@self forage}))
  (cease-effects (end-goal   {@self forage})))

(npc-think starving_buy_go
  (schedule on-commit)
  (if-blocked hold)
  (role @self (believes {@self starving}))
  ; The known provisions_shop is preferred; else a role-cast shop the NPC KNOWS
  ; (nearest, weighted). Replaces the (venue ...) fallback.
  (role ?go_dest [k building shop] (select (score (near @self ?go_dest)) (policy roulette)))
  (bind (target {@self provisions_shop ?}) ?shop)
  (when (and (> (attr @self appetite) 1.3)
             (> (target {@self wealth}) 0.2)
             (not (at-place-kind [k building shop]))))
  (utility 135)
  (effects
    (if (is-entity ?shop)
        (then (begin-goal {@self enter ?shop}))
        (else (begin-goal {@self enter ?go_dest}))))
  (cease-effects
    (if (is-entity ?shop)
        (then (end-goal {@self enter ?shop}))
        (else (end-goal {@self enter ?go_dest})))))

; Steal: the pauper's act - at a shop with no wealth, the mouthful goes on the
; ledger (the shop owner is the victim). The row lands only when something was
; actually eaten - forage_act appends it inside its shop branch.
(npc-think starving_steal
  (schedule on-commit)
  (if-blocked hold)
  (role @self (believes {@self starving}))
  (when (and (> (attr @self appetite) 1.3)
             (not (> (target {@self wealth}) 0.2))
             (at-place-kind [k building shop])))
  (utility 130)
  (effects       (begin-goal {@self forage}))
  (cease-effects (end-goal   {@self forage})))

(npc-think starving_steal_go
  (schedule on-commit)
  (if-blocked hold)
  (role @self (believes {@self starving}))
  (role ?go_dest [k building shop] (select (score (near @self ?go_dest)) (policy roulette)))
  (bind (target {@self provisions_shop ?}) ?shop)
  (when (and (> (attr @self appetite) 1.3)
             (not (> (target {@self wealth}) 0.2))
             (not (at-place-kind [k building shop]))))
  (utility 130)
  (effects
    (if (is-entity ?shop)
        (then (begin-goal {@self enter ?shop}))
        (else (begin-goal {@self enter ?go_dest}))))
  (cease-effects
    (if (is-entity ?shop)
        (then (end-goal {@self enter ?shop}))
        (else (end-goal {@self enter ?go_dest})))))

; TERMINAL step (act_body_purification): the forage act is now PROPOSED, guarded by being AT a
; food source, not auto-promoted by the bare {@self forage} goal. The four food-source desires
; above hold {@self forage} only while a source is reachable (carried / home pantry / shop); the
; forage act promotes ONLY here. The readiness is the union of the arrived conditions the go rungs
; negate (carried anywhere / at home / at a shop); forage_act's branch ORDER picks the source. The
; proposal inherits the starving-band utility (141/140/135/130) from the {@self forage} goal it
; /causes (via the (goal ...) gate).
(npc-think forage_at_source
  (schedule always)
  (goal    {@self forage})
  (when    (or (control [k food])
               (at-home)
               (at-place-kind [k building shop])))
  (effects (propose {@self forage})))
