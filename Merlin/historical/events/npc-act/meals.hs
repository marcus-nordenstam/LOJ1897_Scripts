; ----------------------------------------------------------------------------
; meals - the MEAL-TIME lanes (npc-act): breakfast, lunch and supper, timed by
; the household mealtimes the COOK set (npc-think/household.hs:
; set_mealtimes / ask_mealtimes / answer_mealtimes) and eaten on the
; physiology the stepper runs (tell-only comms plan, rulings 10-13).
;
; UTILITY IS PROXIMITY TO THE MEALTIME, NEVER HUNGER (ruling 10): each lane
; is eligible only inside its believed 2h window ({?home breakfast_hour /
; lunch_hour / supper_hour} + 2). Hunger is pure physiology - it accrues
; 1/16 per hour at the completion seam (sleep included - you wake hungry)
; and each meal reduces it content-side here - and enters the lanes only as
; the ELIGIBILITY gate (> hunger 0.25): just-fed NPCs skip the next window,
; which is also the once-per-window dedup.
;
; FOOD KNOWLEDGE IS PER-MIND (the no-omniscience rule): every stock gate
; reads the asker's OWN whereabouts beliefs via (count-believed-located
; [k food] <place>) - what this NPC has actually SEEN lying about the house
; - and every consume acts on a specific believed item. Perception keeps the
; ledger honest: the household shares one parked room, the cook puts the
; shopping away in it, and everyone's completion-instant room walk mints the
; {<loaf> location <room>} beliefs the gates read. A stale belief (the loaf
; someone else ate) fails its bind harmlessly. Keep the count op LAST in
; each (when) so the belief fold only runs on otherwise-eligible NPCs.
;
; THREE MEALS, THREE SOCIAL REGISTERS (ruling 13):
;   breakfast  - at home, 30 min, SILENT. No approach lane: you breakfast in
;                the house you woke in, or not at all. Utility 82 - a shade
;                over the work lane so the commuter eats before leaving
;                (work-starts-soon makes work eligible 2h ahead), while an
;                early shift already AT the workplace is untouched (the
;                at-home gate fails there).
;   lunch      - two venues, one hour band:
;                  work_lunch: AT the workplace at midday - the CO-WORKER
;                  catch-up/gossip channel (colleague turns, never the
;                  family payload). Utility 85 beats the shift's 80 for the
;                  lunch break; a driven man (the work-factor follow-up) may
;                  out-earn it and work through - flavour, not a bug.
;                  home lunch: the at-home NPC's silent midday meal per the
;                  cook's lunch_hour.
;   supper     - at home, 60 MINUTES - the FAMILY/KIN talk channel. The
;                hour-long dwell inside the 2h window is what guarantees
;                arrival overlap: talk delivers at each diner's completion
;                instant, when the late arrivals are already at table. The
;                approach lane opens an hour before the window so travel
;                (30 min) lands the family home by the cook's hour. Utility
;                78: under work's 80 (an evening shift eats late or not at
;                all), over leisure and the evening sleep climb until
;                fatigue ~0.87.
;
; Meal records are punctual {@self dine <venue> [k <meal>]} act-memories
; (the evidence layer's "dined at <venue>, at <meal>" - the future
; poison-dosing pass keys on them). Being under attack gates every lane out
; (the fight lane owns the moment).
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
(hsim-event idle_at_home
  (intra-day)
  (when (and (not (under-attack))
             (at-home)
             (bind {@self home ?home})))
  (utility 2)
  (effects (stay (min 180
                      (minutes-until-hour (target {?home breakfast_hour}))
                      (minutes-until-hour (target {?home lunch_hour}))
                      (minutes-until-hour (target {?home supper_hour}))))))

; ---------------------------------------------------------------- breakfast

(hsim-event breakfast
  (intra-day)
  (when (and (not (under-attack))
             (at-home)
             (> (attr @self hunger) 0.25)
             (bind {@self home ?home})
             (bind {?home breakfast_hour ?h})
             (>= (now-hour) ?h)
             ; Breakfast keeps a 3h window (the one exception to the 2h rule):
             ; the jobless household wakes at 8, after a 6-8 window has shut -
             ; breakfast is come-as-you-wake.
             (< (now-hour) (+ ?h 3))
             (> (count-believed-located [k food] ?home) 0)))
  (utility 82)
  (effects (act breakfast_episode 30)))

(hsim-event breakfast_episode
  (schedule (completion-only))
  (effects
    ; A food prop is a PERSON-DAY of provisions: the day's stock drawdown
    ; happens at supper (one per diner); breakfast and lunch eat from it
    ; without a separate destroy.
    (set-attr @self hunger (max 0 (- (attr @self hunger) 0.35)))
    (bind {@self home ?home})
    (if (is-entity ?home)
        (begin-ended-belief {@self dine ?home [k breakfast]}))
    ))

; -------------------------------------------------------------------- lunch

; The worker's lunch: at the workplace at midday, with whoever else works
; there - the colleague talk channel. No travel (you eat where you stand).
(hsim-event work_lunch
  (intra-day)
  (when (and (not (under-attack))
             (> (attr @self hunger) 0.25)
             (bind {@self employer ?org})
             (bind {?org workplace ?wp})
             (at-place ?wp)
             (>= (now-hour) 12)
             (< (now-hour) 14)))
  (utility 85)
  (effects (act work_lunch_episode 40)))

(hsim-event work_lunch_episode
  (schedule (completion-only))
  (effects
    (set-attr @self hunger (max 0 (- (attr @self hunger) 0.35)))
    (bind {@self employer ?org})
    (bind {?org workplace ?wp})
    (if (is-entity ?wp)
        (begin-ended-belief {@self dine ?wp [k luncheon]}))
    ; Colleague talk, turn 1 - own news / the workplace self-disclosure
    ; ladder (hearer-min gates each fact by the lowest-tier colleague
    ; present).
    (tell (top-untold-belief @self _ @self
            job calling interest
            spouse fiancee child))
    ; Colleague talk, turn 2 - circle news about others (tier-exempt; the
    ; scandal head stays gossip.hs's).
    (tell (top-untold-belief @self _ _
            spouse fiancee child circumstances_of_death))
    ))

; The at-home midday meal (the jobless, the housewife, the child): silent,
; per the cook's lunch_hour.
(hsim-event home_lunch
  (intra-day)
  (when (and (not (under-attack))
             (at-home)
             (> (attr @self hunger) 0.25)
             (bind {@self home ?home})
             (bind {?home lunch_hour ?h})
             (>= (now-hour) ?h)
             (< (now-hour) (+ ?h 2))
             (> (count-believed-located [k food] ?home) 0)))
  (utility 76)
  (effects (act home_lunch_episode 30)))

(hsim-event home_lunch_episode
  (schedule (completion-only))
  (effects
    ; No stock drawdown - see breakfast_episode (person-day grain).
    (set-attr @self hunger (max 0 (- (attr @self hunger) 0.35)))
    (bind {@self home ?home})
    (if (is-entity ?home)
        (begin-ended-belief {@self dine ?home [k luncheon]}))
    ))

; ------------------------------------------------------------------- supper

; APPROACH - the hour before the cook's window through its end, holding real
; hunger and not home: head home. Travel is 30 min, so opening the lane an
; hour early lands the household at table by the cook's hour.
(hsim-event supper_go_home
  (intra-day)
  (when (and (not (under-attack))
             (> (attr @self hunger) 0.25)
             (bind {@self home ?home})
             (bind {?home supper_hour ?h})
             (>= (now-hour) (- ?h 1))
             (< (now-hour) (+ ?h 2))
             (not (at-home))))
  (utility 78)
  (effects (go @self ?home)))

; EXECUTE - at home inside the cook's window: the hour at table.
(hsim-event supper
  (intra-day)
  (when (and (not (under-attack))
             (at-home)
             (> (attr @self hunger) 0.25)
             (bind {@self home ?home})
             (bind {?home supper_hour ?h})
             (>= (now-hour) ?h)
             (< (now-hour) (+ ?h 2))
             (> (count-believed-located [k food] ?home) 0)))
  (utility 78)
  (effects (act supper_episode 60)))

; The supper COMPLETION: the meal record, the family table talk, the big
; meal's hunger reset. @self is the diner; co-presence is whoever is at the
; house when the completion lands.
(hsim-event supper_episode
  (schedule (completion-only))
  (effects
    ; The day's stock drawdown: one PERSON-DAY prop per diner. The diner
    ; eats a loaf they KNOW of (their own whereabouts belief); the fetch
    ; from the larder is abstracted inside the hour at table. A belief
    ; gone stale (the loaf a sibling already ate) fails the bind harmlessly
    ; and the next room walk corrects the larder ledger.
    (bind {@self home ?sh})
    (if (is-entity ?sh)
        (do
          (bind (believed-located [k food] ?sh) ?meal)
          (if (is-entity ?meal)
              (do
                ; The eater KNOWS the loaf is gone (their own act): end every
                ; other standing belief about it, mint the ongoing {?meal
                ; condition consumed} - the realization contract. Must run
                ; BEFORE the destroy (the item must still resolve).
                (realize-destroyed ?meal [k condition consumed])
                (destroy-entity ?meal)))))
    (set-attr @self hunger 0)
    ; The act-memory: dined at home, at supper (punctual, born-ended).
    ; Guarded like attend_episode: a home lost mid-act (rare) fails the
    ; bind and the record is simply skipped.
    (bind {@self home ?home})
    (if (is-entity ?home)
        (begin-ended-belief {@self dine ?home [k supper]}))
    ; Table talk, turn 1 - self-news / self-disclosure. Family news first,
    ; then the disclosure ladder; the hearer-min gate caps each fact by the
    ; lowest-tier ear present (a servant at table caps the family's talk).
    (tell (top-untold-belief @self _ @self
            spouse fiancee child
            job interest birthplace
            calling value life_aim lover))
    ; Table talk, turn 2 - household / circle news about others (tier-exempt;
    ; the scandal head stays with gossip.hs).
    (tell (top-untold-belief @self _ _
            spouse fiancee child circumstances_of_death))
    ; The TABLE ANNOUNCEMENT: now and then a diner who knows the house's
    ; hours re-airs them ("supper at six, as always"). Rides the spoken
    ; wire's (this [k building]) deixis, so everyone at table - children
    ; under asking age included (ruling: ages 0-2 learn mealtimes purely by
    ; hearing this) - adopts them onto THEIR OWN home object. Adoption is
    ; idempotent; the chance keeps the say-record volume low.
    (if (and (chance 0.25)
             (bind {?home breakfast_hour ?b})
             (bind {?home lunch_hour ?l})
             (bind {?home supper_hour ?s}))
        (tell {?home breakfast_hour ?b}
              {?home lunch_hour ?l}
              {?home supper_hour ?s}))
    ))

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
; Errand-band utility (55-56): above leisure, below the work shift; take
; outbids the walks by a point so arrival flips travel into the stop.

(hsim-event provision_go_known
  (intra-day)
  (bind (target {@self provisions_shop ?}) ?shop)
  (when (and (not (under-attack))
             (has-goal provision)
             (is-entity ?shop)
             (not (at-place ?shop))))
  (utility 55)
  (effects (go @self ?shop)))

(hsim-event provision_search
  (intra-day)
  (bind (target {@self provisions_shop ?}) ?shop)
  (when (and (not (under-attack))
             (has-goal provision)
             (not (is-entity ?shop))
             (not (at-place-kind [k building shop]))))
  (utility 55)
  (effects (go @self (venue [k building shop]))))

(hsim-event provision_take
  (intra-day)
  (when (and (not (under-attack))
             (has-goal provision)
             (at-place-kind [k building shop])))
  (utility 56)
  (effects (act provision_episode 15)))

(hsim-event provision_episode
  (schedule (completion-only))
  (effects
    (bind (current-building @self) ?shop)
    (if (is-entity ?shop)
        ; The counter stop: work the shop's rooms and take a BASKETFUL of
        ; food - /limit 6 is the basket (a shelf holds ~80; the cap keeps
        ; the carry and the stow-goal count physical). Physically present,
        ; physically browsing: the rooms' actual contents are what her
        ; hands reach (the terminal-steal precedent). Each find also
        ; teaches / refreshes WHERE provisions are sold - the venue belief
        ; the go_known and starving lanes route on (idempotent, @excl).
        (for-each ?room (attr-values ?shop parts [k interior_space room])
          (for-each ?item (attr-values ?room contents [k food]) /limit 6
            (do
              (take-item ?item)
              (begin-goal {@self stow ?item})
              (begin-belief {@self provisions_shop ?shop})))))
    (end-goal {@self provision})))

; EATING OUT - the fallback dining room (ruling 14): no food at home (as far
; as the diner KNOWS) in the supper window and wealth permits -> a pub supper
; (lower / middle), a restaurant one for the upper class. Utility 70: under
; the home supper (whose stock gate already failed if this is eligible),
; over leisure.

(hsim-event eat_out_go_pub
  (intra-day)
  (when (and (not (under-attack))
             (> (attr @self hunger) 0.25)
             (bind {@self home ?home})
             (bind {?home supper_hour ?h})
             (>= (now-hour) (- ?h 1))
             (< (now-hour) (+ ?h 2))
             (> (target {@self wealth}) 0.2)
             (not (believes {@self class_situation [k upper]}))
             (not (at-place-kind [k building pub]))
             (= (count-believed-located [k food] ?home) 0)))
  (utility 70)
  (effects (go @self (venue [k building pub]))))

(hsim-event eat_out_go_restaurant
  (intra-day)
  (when (and (not (under-attack))
             (> (attr @self hunger) 0.25)
             (bind {@self home ?home})
             (bind {?home supper_hour ?h})
             (>= (now-hour) (- ?h 1))
             (< (now-hour) (+ ?h 2))
             (> (target {@self wealth}) 0.2)
             (believes {@self class_situation [k upper]})
             (not (at-place-kind [k building restaurant]))
             (= (count-believed-located [k food] ?home) 0)))
  (utility 70)
  (effects (go @self (venue [k building restaurant]))))

(hsim-event eat_out_pub
  (intra-day)
  (when (and (not (under-attack))
             (> (attr @self hunger) 0.25)
             (at-place-kind [k building pub])
             (bind {@self home ?home})
             (bind {?home supper_hour ?h})
             (>= (now-hour) (- ?h 1))
             (< (now-hour) (+ ?h 2))
             (= (count-believed-located [k food] ?home) 0)))
  (utility 70)
  (effects (act eat_out_episode 45)))

(hsim-event eat_out_restaurant
  (intra-day)
  (when (and (not (under-attack))
             (> (attr @self hunger) 0.25)
             (at-place-kind [k building restaurant])
             (bind {@self home ?home})
             (bind {?home supper_hour ?h})
             (>= (now-hour) (- ?h 1))
             (< (now-hour) (+ ?h 2))
             (= (count-believed-located [k food] ?home) 0)))
  (utility 70)
  (effects (act eat_out_episode 45)))

; The venue kitchen is abstract in v1 (no prop consumed); the dine record
; lands at the venue - the evidence layer's "dined at the Crown, at supper".
(hsim-event eat_out_episode
  (schedule (completion-only))
  (effects
    (set-attr @self hunger (max 0 (- (attr @self hunger) 0.6)))
    (bind (current-building @self) ?venue)
    (if (is-entity ?venue)
        (begin-ended-belief {@self dine ?venue [k supper]}))
    ))

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
(hsim-event starving_eat_carried
  (intra-day)
  (bind (goal-focus stow) ?item)
  (when (and (not (under-attack))
             (> (attr @self hunger) 1.3)
             (is-entity ?item)
             (is-a ?item [k food])))
  (utility 141)
  (effects (act starving_eat_carried_episode 10)))

(hsim-event starving_eat_carried_episode
  (schedule (completion-only))
  (effects
    (bind (goal-focus stow) ?item)
    (if (and (is-entity ?item) (is-a ?item [k food]))
        (do
          (realize-destroyed ?item [k condition consumed])
          (destroy-entity ?item)
          (end-goal {@self stow})))
    (set-attr @self hunger (max 0 (- (attr @self hunger) 0.5)))))

(hsim-event starving_pantry
  (intra-day)
  (when (and (not (under-attack))
             (> (attr @self hunger) 1.3)
             (at-home)
             (bind {@self home ?home})
             (> (count-believed-located [k food] ?home) 0)))
  (utility 140)
  (effects (act starving_eat_episode 10)))

(hsim-event starving_go_home
  (intra-day)
  (when (and (not (under-attack))
             (> (attr @self hunger) 1.3)
             (not (at-home))
             (bind {@self home ?home})
             (> (count-believed-located [k food] ?home) 0)))
  (utility 138)
  (effects (go @self ?home)))

(hsim-event starving_eat_episode
  (schedule (completion-only))
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
(hsim-event starving_buy_go
  (intra-day)
  (bind (target {@self provisions_shop ?}) ?shop)
  (when (and (not (under-attack))
             (> (attr @self hunger) 1.3)
             (> (target {@self wealth}) 0.2)
             (not (at-place-kind [k building shop]))))
  (utility 135)
  (effects
    (if (is-entity ?shop)
        (go @self ?shop)
        (go @self (venue [k building shop])))))

(hsim-event starving_buy
  (intra-day)
  (when (and (not (under-attack))
             (> (attr @self hunger) 1.3)
             (> (target {@self wealth}) 0.2)
             (at-place-kind [k building shop])))
  (utility 135)
  (effects (act starving_buy_episode 10)))

(hsim-event starving_buy_episode
  (schedule (completion-only))
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
(hsim-event starving_steal_go
  (intra-day)
  (bind (target {@self provisions_shop ?}) ?shop)
  (when (and (not (under-attack))
             (> (attr @self hunger) 1.3)
             (not (> (target {@self wealth}) 0.2))
             (not (at-place-kind [k building shop]))))
  (utility 130)
  (effects
    (if (is-entity ?shop)
        (go @self ?shop)
        (go @self (venue [k building shop])))))

(hsim-event starving_steal
  (intra-day)
  (when (and (not (under-attack))
             (> (attr @self hunger) 1.3)
             (not (> (target {@self wealth}) 0.2))
             (at-place-kind [k building shop])))
  (utility 130)
  (effects (act starving_steal_episode 10)))

(hsim-event starving_steal_episode
  (schedule (completion-only))
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
