; ----------------------------------------------------------------------------
; meals - the npc-ACT half of the UNIFIED eat lane (the desires live in
; npc-think/meals.hs). This file holds the meals-local define-macros
; (larder_target / carry_cap) and the acts: dwell_act, eat_act, provision_act,
; forage_act.
;
; ONE act-goal serves every routine meal: {@self eat [k <meal>] <place>} -
; target = the meal occasion (breakfast | lunch | supper), aux = the place
; eaten at. A desire mints it in its window; the <place> drives a leaf-first
; approach (eat_go, like drink/worship); at the place it promotes to the shared
; eat_act. The begun-then-ended act-belief IS the meal memory (interval = the
; sitting) - there is no separate `dine` record.
;
; TABLE TALK is unified in eat_act: one self-disclosure turn + one circle-news
; turn, the hearer-min tier-gate clamping each fact by the lowest-tier ear
; present. Only a HOME SUPPER consumes (one person-day food prop per diner);
; breakfast / lunch / eating-out are abstract. Being under attack gates every
; lane out (the fight lane owns the moment).
; ----------------------------------------------------------------------------

; The at-home idle dwell: the leaf when nothing else pulls, CAPPED to yield at the
; next mealtime (so a multi-hour idle never leaps clean over a 2h meal window). Its
; completion re-deliberates, giving the meal lanes their instant.
(npc-act dwell_act
  (when (bind {@self dwell ?home}))
  (duration (min 180
                 (minutes-until-hour (target {?home breakfast_hour}))
                 (minutes-until-hour (target {?home lunch_hour}))
                 (minutes-until-hour (target {?home supper_hour}))))
  (act-effects (end-act {@self dwell ?home})))

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
    ; Self-disclosure: say ONE untold piece of my own profile at this table. for-each-belief
    ; walks my {@self <label> ?} beliefs, binding the matched label + target; (utterable-msg)
    ; dedups against my SAY memories; (break) stops at the first untold fact.
    (for-each-belief {@self spouse|fiancee|child|job|interest|birthplace|home|mother|father|sibling|friend|nationality|calling|value|life_aim|lover:?label ?tgt}
      (do
        (if (not (believes {@self SAY (utterable-msg {@self ?label ?tgt}) _}))
            (do (tell {@self ?label ?tgt}) (break)))))
    (tell (top-untold-belief @self _ _
            spouse fiancee child condition circumstances_of_death))
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

; (provision_act - the counter stop - lives in npc-act/provision_act.hs;
; the general put-down completion in npc-act/bring_act.hs.)

; The forage act: the {@self forage} goal, at a food source, promotes here. It
; consumes ONE food item from the highest-priority source available and reduces
; hunger. Branch order IS the ladder: carried > pantry > shop (buy if wealth, else
; steal, the mouthful on the crime ledger).
(npc-act forage_act
  (when (believes {@self forage}))
  (duration 10)
  (act-effects
    (bind (count-controlled @self [k food]) ?ncarried)
    (bind {@self home ?home})
    (if (> ?ncarried 0)
        ; 1. carried food - the HAND decides, not a goal (a laden walker eats
        ;   from the basket whether or not the delivery intention survived).
        (for-each ?item (attr-values @self control [k food]) /limit 1
          (do
            (realize-destroyed ?item [k condition consumed])
            (destroy-entity ?item)))
        (do
          (bind (believed-located [k food] ?home) ?pantry)
          (if (and (at-home) (is-entity ?pantry))
              ; 2. the home pantry.
              (do
                (realize-destroyed ?pantry [k condition consumed])
                (destroy-entity ?pantry))
              (if (at-place-kind [k building shop])
                  ; 3. at a shop: eat one item; buy if wealth, else STEAL (ledger).
                  (do
                    (bind (current-building @self) ?shop)
                    (if (is-entity ?shop)
                        (for-each ?room (attr-values ?shop parts [k interior_space room])
                          (for-each ?item (attr-values ?room contents [k food]) /limit 1
                            (do
                              (realize-destroyed ?item [k condition consumed])
                              (destroy-entity ?item)
                              (begin-belief {@self provisions_shop ?shop})
                              (if (not (> (target {@self wealth}) 0.2))
                                  (crime-ledger-append @self (owner-of ?shop) steal steal _ _)))))))))))
    ; The forage sitting IS a meal's hunger relief, whether or not the specific
    ; believed item still resolved (a stale belief - a sibling ate the loaf - must
    ; not re-arm the >1.3 gate and loop). Reduce unconditionally, like the old
    ; starving episodes did.
    (set-attr @self hunger (max 0 (- (attr @self hunger) 0.5)))
    (end-act {@self forage})
    (end-goal {@self forage})))
