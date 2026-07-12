; ----------------------------------------------------------------------------
; meals - the UNIFIED eat lane, timed by the household mealtimes the COOK set
; (npc-think/household.hs: set_mealtimes / ask_mealtimes / answer_mealtimes)
; and eaten on the physiology the stepper runs (tell-only comms plan).
;
; ONE act-goal serves every routine meal: {@self eat [k <meal>] <place>} -
; target = the meal occasion (breakfast | lunch | supper), aux = the place
; eaten at. A desire mints it in its window; the <place> drives a leaf-first
; approach (eat_go, like drink/worship); at the place it promotes to the shared
; eat_act. The begun-then-ended act-belief IS the meal memory (interval = the
; sitting) - there is no separate `dine` record.
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
;
; TABLE TALK is unified in eat_act: one self-disclosure turn + one circle-news
; turn, the hearer-min tier-gate clamping each fact by the lowest-tier ear
; present. Only a HOME SUPPER consumes (one person-day food prop per diner);
; breakfast / lunch / eating-out are abstract. Being under attack gates every
; lane out (the fight lane owns the moment).
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
  (when (and (not (under-attack))
             (at-home)
             (bind {@self home ?home})))
  (utility 2)
  (effects (begin-act {@self dwell ?home}
                      (min 180
                           (minutes-until-hour (target {?home breakfast_hour}))
                           (minutes-until-hour (target {?home lunch_hour}))
                           (minutes-until-hour (target {?home supper_hour}))))))

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
  (when (and (not (under-attack))
             (at-home)
             (> (attr @self hunger) 0.25)
             (bind {@self home ?home})
             (bind {?home breakfast_hour ?h})
             (>= (now-hour) ?h)
             (< (now-hour) (+ ?h 3))
             (> (count-believed-located [k food] ?home) 0)))
  (utility 82)
  (cont-fire-effects (excl-goal {@self eat [k breakfast] ?home})))

; LUNCH at the workplace - the CO-WORKER channel (eat where you stand at midday).
(npc-think want_lunch_work
  (short-term-think)
  (when (and (not (under-attack))
             (> (attr @self hunger) 0.25)
             (bind {@self employer ?org})
             (bind {?org workplace ?wp})
             (at-workplace ?wp)
             (>= (now-hour) 12)
             (< (now-hour) 14)))
  (utility 85)
  (cont-fire-effects (excl-goal {@self eat [k lunch] ?wp})))

; LUNCH at home - the jobless / housewife / child midday meal, per lunch_hour.
(npc-think want_lunch_home
  (short-term-think)
  (when (and (not (under-attack))
             (at-home)
             (> (attr @self hunger) 0.25)
             (bind {@self home ?home})
             (bind {?home lunch_hour ?h})
             (>= (now-hour) ?h)
             (< (now-hour) (+ ?h 2))
             (> (count-believed-located [k food] ?home) 0)))
  (utility 76)
  (cont-fire-effects (excl-goal {@self eat [k lunch] ?home})))

; SUPPER at home - the FAMILY table. The window opens an hour early so eat_go's
; travel (30 min) lands the household home by the cook's hour.
(npc-think want_supper
  (short-term-think)
  (when (and (not (under-attack))
             (> (attr @self hunger) 0.25)
             (bind {@self home ?home})
             (bind {?home supper_hour ?h})
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
  (role ?venue [k building pub] (select (score (near @self ?venue)) (policy roulette)))
  (when (and (not (under-attack))
             (> (attr @self hunger) 0.25)
             (bind {@self home ?home})
             (bind {?home supper_hour ?h})
             (>= (now-hour) (- ?h 1))
             (< (now-hour) (+ ?h 2))
             (> (target {@self wealth}) 0.2)
             (not (believes {@self class_situation [k upper]}))
             (= (count-believed-located [k food] ?home) 0)))
  (utility 70)
  (cont-fire-effects (excl-goal {@self eat [k supper] ?venue})))

(npc-think want_eat_out_restaurant
  (short-term-think)
  (role ?venue [k building restaurant] (select (score (near @self ?venue)) (policy roulette)))
  (when (and (not (under-attack))
             (> (attr @self hunger) 0.25)
             (bind {@self home ?home})
             (bind {?home supper_hour ?h})
             (>= (now-hour) (- ?h 1))
             (< (now-hour) (+ ?h 2))
             (> (target {@self wealth}) 0.2)
             (believes {@self class_situation [k upper]})
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
                (not (in-building ?place))))
  (cont-fire-effects (go-into ?place)))

; ---- the act: one body for every meal, differentiated by the meal-kind -------

; The eat goal, at its place, is the leaf and promotes here. The begun-then-ended
; {@self eat [k <meal>] <place>} act-belief IS the meal memory.
(npc-act eat_act
  (when (bind {@self eat ?meal ?place}))
  ; supper is the hour-long family meal; lunch 40; breakfast 30.
  (duration (if (is-a ?meal [k supper]) 60
             (if (is-a ?meal [k lunch]) 40 30)))
  (act-effects
    (bind {@self home ?home})
    ; ONLY a home supper consumes: one PERSON-DAY food prop per diner. Breakfast
    ; and lunch eat from it without a separate destroy (person-day grain); a pub
    ; / restaurant supper is abstract (the venue kitchen is not modelled). A
    ; belief gone stale (a loaf a sibling already ate) fails the bind harmlessly.
    (if (and (is-a ?meal [k supper]) (= ?place ?home))
        (do
          (bind (believed-located [k food] ?home) ?loaf)
          (if (is-entity ?loaf)
              (do
                (realize-destroyed ?loaf [k condition consumed])
                (destroy-entity ?loaf)))))
    ; HUNGER: a full supper resets; a lighter meal takes the edge off.
    (if (is-a ?meal [k supper])
        (set-attr @self hunger 0)
        (set-attr @self hunger (max 0 (- (attr @self hunger) 0.35))))
    ; TABLE TALK (unified, every meal): self-disclosure then circle news. The
    ; hearer-min tier-gate clamps each fact by the lowest-tier ear present (a
    ; servant at table caps the family's talk); breakfast / home-lunch / pub
    ; meals, silent before, are now tier-limited talkative - intended.
    (tell (top-untold-belief @self _ @self
            spouse fiancee child
            job interest birthplace
            calling value life_aim lover))
    (tell (top-untold-belief @self _ _
            spouse fiancee child circumstances_of_death))
    ; THE TABLE ANNOUNCEMENT (home meals): now and then re-air the house's hours
    ; ("supper at six, as always"), adopted by everyone at table onto their own
    ; home object. Idempotent; the chance keeps the say-record volume low.
    (if (and (= ?place ?home)
             (chance 0.25)
             (bind {?home breakfast_hour ?b})
             (bind {?home lunch_hour ?l})
             (bind {?home supper_hour ?s}))
        (tell {?home breakfast_hour ?b}
              {?home lunch_hour ?l}
              {?home supper_hour ?s}))
    (end-act {@self eat ?meal ?place})))

; -------------------------------------------------------- the food economy

; The steady-state home larder in PERSON-DAYS of food. The cook's weekly run
; tops the larder up to this, so an average household eats through the week
; without the pantry emptying (which would drop every member into the per-NPC
; starving lanes and re-crowd the shop); a large household that outruns it
; leans on plan_provisioning's catch-up / emergency fallbacks. Sized to keep
; the town's food-prop count under the food archetype cap (food.arc, cap 8192 =
; ~60 occupied homes x this + the grocer shelves). A ~2-week larder gives the
; household a multi-day buffer so a single missed weekly run never empties the
; pantry into the starving lanes. MUST match the world-gen starter larder
; (weapon_seed.h k_home_starter_larder) so homes open in steady state.
(define-macro larder_target () 56)

; How many food items a cook carries home in ONE trip. take/put is a one-load
; seam: she grasps at most this, walks home, stows, and makes another weekly
; trip if the larder is still short. MUST stay under the hand's control cap
; (common.arc control array = 12) so one grasp never overflows the hand.
(define-macro carry_cap () 8)

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
  (effects (begin-act {@self provision} 15 provision_episode)))

(npc-think provision_episode
  (on-completion)
  (effects
    (bind (current-building @self) ?shop)
    (bind {@self home ?home})
    (if (is-entity ?shop)
        ; The counter stop: browse the shop's rooms and grab up to a BASKET's
        ; worth of food (carry_cap), never more than the larder is short. The
        ; /limit subtracts what is ALREADY in hand and re-evaluates on each
        ; room, so the basket fills ACROSS rooms and stops at carry_cap total,
        ; never per-room (the hand's control array is one shared 12-slot store).
        ; A near-full larder buys little, a bare one a basketful, a full one
        ; nothing. Physically present, physically browsing: the rooms' actual
        ; contents are what her hands reach (the terminal-steal precedent). Each
        ; find also teaches / refreshes WHERE provisions are sold (the venue
        ; belief the go_known and starving lanes route on). One weekly trip tops
        ; the larder toward larder_target over successive runs.
        (for-each ?room (attr-values ?shop parts [k interior_space room])
          (for-each ?item (attr-values ?room contents [k food])
                    /limit (- (min (carry_cap) (- (larder_target) (count-believed-located [k food] ?home)))
                              (count-controlled @self [k food]))
            (do
              (take-item ?item)
              (begin-goal {@self stow ?item})
              (begin-belief {@self provisions_shop ?shop})))))
    (end-goal {@self provision})))

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

; Eat what you carry: the laden cook (or laden thief) whose FIRST standing
; stow goal is a food item eats it on the spot. (goal-focus stow) and
; (end-goal {@self stow}) walk the same goal bucket in the same order, so
; the goal ended is the goal gated on.
(npc-think starving_eat_carried
  (short-term-think)
  (bind (goal-focus stow) ?item)
  (when (and (not (under-attack))
             (> (attr @self hunger) 1.3)
             (is-entity ?item)
             (is-a ?item [k food])))
  (utility 141)
  (effects (begin-act {@self dine} 10 starving_eat_carried_episode)))

(npc-think starving_eat_carried_episode
  (on-completion)
  (effects
    (bind (goal-focus stow) ?item)
    (if (and (is-entity ?item) (is-a ?item [k food]))
        (do
          (realize-destroyed ?item [k condition consumed])
          (destroy-entity ?item)
          (end-goal {@self stow})))
    (set-attr @self hunger (max 0 (- (attr @self hunger) 0.5)))))

(npc-think starving_pantry
  (short-term-think)
  (when (and (not (under-attack))
             (> (attr @self hunger) 1.3)
             (at-home)
             (bind {@self home ?home})
             (> (count-believed-located [k food] ?home) 0)))
  (utility 140)
  (effects (begin-act {@self dine} 10 starving_eat_episode)))

(npc-think starving_go_home
  (short-term-think)
  (when (and (not (under-attack))
             (> (attr @self hunger) 1.3)
             (not (at-home))
             (bind {@self home ?home})
             (> (count-believed-located [k food] ?home) 0)))
  (utility 138)
  (cont-fire-effects (go-into ?home)))

(npc-think starving_eat_episode
  (on-completion)
  (effects
    (bind {@self home ?home})
    (if (is-entity ?home)
        (do
          (bind (believed-located [k food] ?home) ?meal)
          (if (is-entity ?meal)
              (do
                (realize-destroyed ?meal [k condition consumed])
                (destroy-entity ?meal)))))
    (set-attr @self hunger (max 0 (- (attr @self hunger) 0.5)))))

; Buy: to the shop she knows, else any shop; at the counter, one item eaten
; on the spot (paid-for in the same v1 no-coin sense as provisioning).
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
  (effects
    (if (is-entity ?shop)
        (go-into ?shop)
        (go-into ?go_dest))))

(npc-think starving_buy
  (short-term-think)
  (when (and (not (under-attack))
             (> (attr @self hunger) 1.3)
             (> (target {@self wealth}) 0.2)
             (at-place-kind [k building shop])))
  (utility 135)
  (effects (begin-act {@self dine} 10 starving_buy_episode)))

(npc-think starving_buy_episode
  (on-completion)
  (effects
    (bind (current-building @self) ?shop)
    (if (is-entity ?shop)
        (for-each ?room (attr-values ?shop parts [k interior_space room])
          (for-each ?item (attr-values ?room contents [k food]) /limit 1
            (do
              (realize-destroyed ?item [k condition consumed])
              (destroy-entity ?item)
              ; Finding food here IS learning where provisions are sold.
              (begin-belief {@self provisions_shop ?shop})))))
    (set-attr @self hunger (max 0 (- (attr @self hunger) 0.4)))))

; Steal: the pauper's act - same walk, no wealth, and the mouthful goes on
; the ledger (the owner of the shop is the victim, the loot gone down the
; thief's throat). The row lands only when something was actually eaten -
; walking into an open shop and finding nothing is no crime.
(npc-think starving_steal_go
  (short-term-think)
  ; The known provisions_shop is preferred; else a role-cast shop the NPC KNOWS
  ; (nearest, weighted). Replaces the (venue ...) fallback.
  (role ?go_dest [k building shop] (select (score (near @self ?go_dest)) (policy roulette)))
  (bind (target {@self provisions_shop ?}) ?shop)
  (when (and (not (under-attack))
             (> (attr @self hunger) 1.3)
             (not (> (target {@self wealth}) 0.2))
             (not (at-place-kind [k building shop]))))
  (utility 130)
  (effects
    (if (is-entity ?shop)
        (go-into ?shop)
        (go-into ?go_dest))))

(npc-think starving_steal
  (short-term-think)
  (when (and (not (under-attack))
             (> (attr @self hunger) 1.3)
             (not (> (target {@self wealth}) 0.2))
             (at-place-kind [k building shop])))
  (utility 130)
  (effects (begin-act {@self dine} 10 starving_steal_episode)))

(npc-think starving_steal_episode
  (on-completion)
  (effects
    (bind (current-building @self) ?shop)
    (if (is-entity ?shop)
        (for-each ?room (attr-values ?shop parts [k interior_space room])
          (for-each ?item (attr-values ?room contents [k food]) /limit 1
            (do
              (realize-destroyed ?item [k condition consumed])
              (destroy-entity ?item)
              (begin-belief {@self provisions_shop ?shop})
              (crime-ledger-append @self (owner-of ?shop) steal steal _ _)))))
    (set-attr @self hunger (max 0 (- (attr @self hunger) 0.4)))))
