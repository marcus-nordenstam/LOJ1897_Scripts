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
  (short-term-think)
  (role ?home (believes {@self home ?home}))
  (when (and (not (under-attack))
             (at-home)))
  (utility 2)
  (cont-fire-effects (excl-goal {@self dwell ?home})))

; ============================ the unified eat lane ==========================
; Every routine meal is ONE act-goal {@self eat [k <meal>] <place>}: a desire
; mints it in its window, the <place> drives a leaf-first approach (eat_go), and
; at the place the goal promotes to the shared eat_act. The begun-then-ended
; act-belief IS the meal memory (target = the meal occasion, aux = the place);
; there is no separate dine record.

; ---- the meal desires (mint {@self eat [k <meal>] <place>}) ----------------

; BREAKFAST - at home, come-as-you-wake (3h window, the one exception to the 2h
; rule): you breakfast in the house you woke in or not at all.
(npc-think want_breakfast
  (short-term-think)
  (role ?home (believes {@self home ?home})
              (believes {?home breakfast_hour ?h}))   ; existence cached, ?h binds at fire
  (when (and (not (under-attack))
             (at-home)
             (> (attr @self hunger) 0.25)
             (>= (now-hour) ?h)
             (< (now-hour) (+ ?h 3))
             (> (count-believed-located [k food] ?home) 0)))
  (utility 82)
  (cont-fire-effects (excl-goal {@self eat [k breakfast] ?home})))

; LUNCH at the workplace - the CO-WORKER channel (eat where you stand at midday).
(npc-think want_lunch_work
  (short-term-think)
  (role ?org (believes {@self employer ?org})
             (believes {?org workplace ?wp}))   ; ?wp binds at fire
  (when (and (not (under-attack))
             (> (attr @self hunger) 0.25)
             (at-workplace ?wp)
             (>= (now-hour) 12)
             (< (now-hour) 14)))
  (utility 85)
  (cont-fire-effects (excl-goal {@self eat [k lunch] ?wp})))

; LUNCH at home - the jobless / housewife / child midday meal, per lunch_hour.
(npc-think want_lunch_home
  (short-term-think)
  (role ?home (believes {@self home ?home})
              (believes {?home lunch_hour ?h}))   ; existence cached, ?h binds at fire
  (when (and (not (under-attack))
             (at-home)
             (> (attr @self hunger) 0.25)
             (>= (now-hour) ?h)
             (< (now-hour) (+ ?h 2))
             (> (count-believed-located [k food] ?home) 0)))
  (utility 76)
  (cont-fire-effects (excl-goal {@self eat [k lunch] ?home})))

; SUPPER at home - the FAMILY table. The window opens an hour early so eat_go's
; travel (30 min) lands the household home by the cook's hour.
(npc-think want_supper
  (short-term-think)
  (role ?home (believes {@self home ?home})
              (believes {?home supper_hour ?h}))   ; existence cached, ?h binds at fire
  (when (and (not (under-attack))
             (> (attr @self hunger) 0.25)
             (>= (now-hour) (- ?h 1))
             (< (now-hour) (+ ?h 2))
             (> (count-believed-located [k food] ?home) 0)))
  (utility 78)
  (cont-fire-effects (excl-goal {@self eat [k supper] ?home})))

; EATING OUT - no food at home (as the diner KNOWS) in the supper window and
; wealth permits: a pub supper (lower/middle), a restaurant one (upper). The
; venue is the eat place; eat_go walks there. Utility 70: under the home supper
; (whose stock gate already failed if this is eligible), over leisure.
(npc-think want_eat_out_pub
  (short-term-think)
  ; class gate = CACHED self-gate filter (the belief form, not the live conjunct).
  (role @self (not (believes {@self class_situation [k upper]})))
  (role ?home (believes {@self home ?home})
              (believes {?home supper_hour ?h}))   ; existence cached, ?h binds at fire
  (role ?venue [k building pub] (select (score (near @self ?venue)) (policy roulette)))
  (when (and (not (under-attack))
             (> (attr @self hunger) 0.25)
             (>= (now-hour) (- ?h 1))
             (< (now-hour) (+ ?h 2))
             (> (target {@self wealth}) 0.2)
             (= (count-believed-located [k food] ?home) 0)))
  (utility 70)
  (cont-fire-effects (excl-goal {@self eat [k supper] ?venue})))

(npc-think want_eat_out_restaurant
  (short-term-think)
  ; upper-class only - the CACHED self-gate skips the majority (and the
  ; larder belief-fold below) with zero eval.
  (role @self (believes {@self class_situation [k upper]}))
  (role ?home (believes {@self home ?home})
              (believes {?home supper_hour ?h}))   ; existence cached, ?h binds at fire
  (role ?venue [k building restaurant] (select (score (near @self ?venue)) (policy roulette)))
  (when (and (not (under-attack))
             (> (attr @self hunger) 0.25)
             (>= (now-hour) (- ?h 1))
             (< (now-hour) (+ ?h 2))
             (> (target {@self wealth}) 0.2)
             (= (count-believed-located [k food] ?home) 0)))
  (utility 70)
  (cont-fire-effects (excl-goal {@self eat [k supper] ?venue})))

; ---- the shared approach: the <place> drives a leaf-first go sub-goal --------

; Not yet at the eat place -> head there (go-into, like drink/worship). At the
; place, eat_go stops firing, its go sub-goal is swept, and the eat goal becomes
; the live leaf and promotes to eat_act. For breakfast / home-lunch / work-lunch
; the diner is already at the place, so eat_go never fires.
(npc-think eat_go
  (short-term-think)
  (goal    {@self eat ?meal ?place})
  (when    (and (not (under-attack))
                (not (at-place ?place))))
  (cont-fire-effects (go-into ?place)))

; -------------------------------------------------------- the food economy

; PROVISIONING - the cook keeps the larder stocked (ruling 14). The desire
; (plan_provisioning, npc-think/household.hs) mints {@self goal {@self
; provision}} when the cook BELIEVES the home stock is low; these acts
; drain it over the EXISTING atomic vocabulary - no bespoke verbs:
;
;   provision_go_known : she knows where provisions are sold ({@self
;                        provisions_shop ?shop} - the register read at
;                        orientation, or a past find) -> walk there.
;   provision_search   : no such knowledge -> try A shop ((venue [k building
;                        shop]), the generic kind-approach the pub / church
;                        errands use). The wrong counter teaches her nothing
;                        but costs only the walk; finding food mints the
;                        provisions_shop belief and ends the searching.
;   provision_take     : at a shop with the goal - the counter stop. The
;                        completion takes a BASKETFUL: one take-act per item
;                        (the ONE possession seam), one stow goal per item,
;                        and the generic stow lane (stow.hs) walks her home
;                        laden and puts the food away openly. Like the
;                        weapon purchase path, v1 records no coin movement.
;                        Empty-handed (wrong shop / bare shelf) the errand
;                        still ends - she gives it up until the next
;                        window's think re-arms it.
;
; Completion-band utility (77 walk / 79 take): high enough that the weekly run
; actually COMPLETES rather than oscillating. It beats midday leisure / lunch
; (home_lunch 76) so the cook makes uninterrupted daytime progress to the shop,
; but stays under breakfast (82), work (80) and sleep (100) so she still eats,
; works and sleeps - a working cook simply shops on a day off or after her
; shift. At 55 the errand lost to every meal and the evening supper-go-home
; pull, so the cook never arrived and the town fell through to the (high-
; utility) starving lanes for its food. Take outbids the walks by two points so
; arrival flips travel into the counter stop even against the supper pull (78).

(npc-think provision_go_known
  (short-term-think)
  (goal {@self provision})
  (bind (target {@self provisions_shop ?}) ?shop)
  (when (and (not (under-attack))
             (is-entity ?shop)
             (not (in-building ?shop))))
  (utility 77)
  (cont-fire-effects (go-into ?shop)))

(npc-think provision_search
  (short-term-think)
  (goal {@self provision})
  ; No known provisions_shop: role-cast a shop the NPC KNOWS (nearest preferred,
  ; weighted) and head there. No known shop -> no fire. Replaces (venue ...).
  (role ?go_dest [k building shop] (select (score (near @self ?go_dest)) (policy roulette)))
  (bind (target {@self provisions_shop ?}) ?shop)
  (when (and (not (under-attack))
             (not (is-entity ?shop))
             (not (at-place-kind [k building shop]))))
  (utility 77)
  (cont-fire-effects (go-into ?go_dest)))

(npc-think provision_take
  (short-term-think)
  (goal {@self provision})
  (when (and (not (under-attack))
             (at-place-kind [k building shop])))
  (utility 79)
  (cont-fire-effects (begin-goal {@self provision})))

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

; The four food-source DESIRES all push utility onto one {@self forage} goal (the
; ladder is by branch ORDER in forage_act, not by competing goals): eat what you
; carry (141) > eat the pantry (140) > buy at a shop (135) > STEAL and eat (130).
; The GO lanes (already goal-based) route to home / a shop when not there.

; Eat what you carry: the laden cook (or laden thief) whose FIRST standing stow
; goal is a food item.
(npc-think starving_eat_carried
  (short-term-think)
  (goal {@self stow ?item})
  (when (and (not (under-attack))
             (> (attr @self hunger) 1.3)
             (is-entity ?item)
             (is-a ?item [k food])))
  (utility 141)
  (cont-fire-effects (begin-goal {@self forage})))

(npc-think starving_pantry
  (short-term-think)
  (role ?home (believes {@self home ?home}))
  (when (and (not (under-attack))
             (> (attr @self hunger) 1.3)
             (at-home)
             (> (count-believed-located [k food] ?home) 0)))
  (utility 140)
  (cont-fire-effects (begin-goal {@self forage})))

(npc-think starving_go_home
  (short-term-think)
  (role ?home (believes {@self home ?home}))
  (when (and (not (under-attack))
             (> (attr @self hunger) 1.3)
             (not (at-home))
             (> (count-believed-located [k food] ?home) 0)))
  (utility 138)
  (cont-fire-effects (go-into ?home)))

; Buy: at a shop with wealth, one item eaten on the spot (paid-for in the v1
; no-coin sense as provisioning).
(npc-think starving_buy
  (short-term-think)
  (when (and (not (under-attack))
             (> (attr @self hunger) 1.3)
             (> (target {@self wealth}) 0.2)
             (at-place-kind [k building shop])))
  (utility 135)
  (cont-fire-effects (begin-goal {@self forage})))

(npc-think starving_buy_go
  (short-term-think)
  ; The known provisions_shop is preferred; else a role-cast shop the NPC KNOWS
  ; (nearest, weighted). Replaces the (venue ...) fallback.
  (role ?go_dest [k building shop] (select (score (near @self ?go_dest)) (policy roulette)))
  (bind (target {@self provisions_shop ?}) ?shop)
  (when (and (not (under-attack))
             (> (attr @self hunger) 1.3)
             (> (target {@self wealth}) 0.2)
             (not (at-place-kind [k building shop]))))
  (utility 135)
  (cont-fire-effects
    (if (is-entity ?shop)
        (go-into ?shop)
        (go-into ?go_dest))))

; Steal: the pauper's act - at a shop with no wealth, the mouthful goes on the
; ledger (the shop owner is the victim). The row lands only when something was
; actually eaten - forage_act appends it inside its shop branch.
(npc-think starving_steal
  (short-term-think)
  (when (and (not (under-attack))
             (> (attr @self hunger) 1.3)
             (not (> (target {@self wealth}) 0.2))
             (at-place-kind [k building shop])))
  (utility 130)
  (cont-fire-effects (begin-goal {@self forage})))

(npc-think starving_steal_go
  (short-term-think)
  (role ?go_dest [k building shop] (select (score (near @self ?go_dest)) (policy roulette)))
  (bind (target {@self provisions_shop ?}) ?shop)
  (when (and (not (under-attack))
             (> (attr @self hunger) 1.3)
             (not (> (target {@self wealth}) 0.2))
             (not (at-place-kind [k building shop]))))
  (utility 130)
  (cont-fire-effects
    (if (is-entity ?shop)
        (go-into ?shop)
        (go-into ?go_dest))))
