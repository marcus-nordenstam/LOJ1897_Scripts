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
; TABLE TALK is its OWN role-bearing event (npc-think/intra-day/table_talk_think.hs)
; so it can bind the diner it addresses and dedup per-listener; eat_act keeps only
; the food + the house-hours re-air. Only a HOME SUPPER consumes (one person-day
; food prop per diner); breakfast / lunch / eating-out are abstract. Being under
; attack gates every lane out (the fight lane owns the moment).
; ----------------------------------------------------------------------------

; The at-home idle dwell: the leaf when nothing else pulls, CAPPED to yield at the
; next mealtime (so a multi-hour idle never leaps clean over a 2h meal window). Its
; completion re-deliberates, giving the meal lanes their instant.
(npc-action dwell_act
  (act {@self dwell ?home})
  (duration (min 180
                 (minutes-until-hour (target {?home breakfast_hour}))
                 (minutes-until-hour (target {?home lunch_hour}))
                 (minutes-until-hour (target {?home supper_hour}))))
  (act-effects (set-outcome {@self dwell ?home} succ)))

; ---- the act: one body for every meal, differentiated by the meal-kind -------

; The eat goal, at its place, is the leaf and promotes here. The begun-then-ended
; {@self eat [k <meal>] <place>} act-belief IS the meal memory.
(npc-action eat_act
  (act {@self eat ?meal ?place})
  ; supper is the hour-long family meal; lunch 40; breakfast 30.
  (duration (if (is-a ?meal [k supper]) (then 60)
             (else (if (is-a ?meal [k lunch]) (then 40) (else 30)))))
  (act-effects
    (bind {@self home ?home})
    ; ONLY a home supper consumes: one PERSON-DAY food prop per diner. Breakfast
    ; and lunch eat from it without a separate destroy (person-day grain); a pub
    ; / restaurant supper is abstract (the venue kitchen is not modelled). A
    ; belief gone stale (a loaf a sibling already ate) fails the bind harmlessly.
    (if (and (is-a ?meal [k supper]) (= ?place ?home))
        (then
          (bind (believed-located [k food] ?home) ?loaf)
          (if (is-entity ?loaf)
              (then
                (realize-destroyed ?loaf [k condition consumed])
                (destroy-entity ?loaf)))))
    ; HUNGER: a full supper resets; a lighter meal takes the edge off.
    (if (is-a ?meal [k supper])
        (then (set-attr @self hunger 0))
        (else (set-attr @self hunger (max 0 (- (attr @self hunger) 0.35)))))
    ; TABLE TALK (self-disclosure + circle news) is its own role-bearing event now
    ; (npc-think/intra-day/table_talk_think.hs) - it binds the listener it speaks to.
    ; THE TABLE ANNOUNCEMENT (home meals): now and then re-air the house's hours
    ; ("supper at six, as always"), adopted by everyone at table onto their own
    ; home object. Idempotent; the chance keeps the say-record volume low.
    (if (and (= ?place ?home)
             (chance 0.25)
             (bind {?home breakfast_hour ?b})
             (bind {?home lunch_hour ?l})
             (bind {?home supper_hour ?s}))
        (then (tell {?home breakfast_hour ?b}
              {?home lunch_hour ?l}
              {?home supper_hour ?s})))
    (set-outcome {@self eat ?meal ?place} succ)))

; (provision_act - the counter stop - lives in npc-act/provision_act.hs;
; the general put-down completion in npc-act/bring_act.hs.)

; The forage act: the {@self forage} goal, at a food source, promotes here. It
; consumes ONE food item from the highest-priority source available and reduces
; hunger. Branch order IS the ladder: carried > pantry > shop (buy if wealth, else
; steal, the mouthful on the crime ledger).
(npc-action forage_act
  (act {@self forage})
  (duration 10)
  (act-effects
    (bind (count-controlled @self [k food]) ?ncarried)
    (bind {@self home ?home})
    (if (> ?ncarried 0)
        ; 1. carried food - the HAND decides, not a goal (a laden walker eats
        ;   from the basket whether or not the delivery intention survived).
        (then (for-each ?item (attr-values @self control [k food]) /limit 1
          (do
            (realize-destroyed ?item [k condition consumed])
            (destroy-entity ?item))))
        (else
          (bind (believed-located [k food] ?home) ?pantry)
          (if (and (at-home) (is-entity ?pantry))
              ; 2. the home pantry.
              (then
                (realize-destroyed ?pantry [k condition consumed])
                (destroy-entity ?pantry))
              (else (if (at-place-kind [k building shop])
                  ; 3. at a shop: eat one item; buy if wealth, else STEAL (ledger).
                  (then
                    (bind (current-building @self) ?shop)
                    (if (is-entity ?shop)
                        (then (for-each ?room (attr-values ?shop parts [k interior_space room])
                          (for-each ?item (attr-values ?room contents [k food]) /limit 1
                            (do
                              (realize-destroyed ?item [k condition consumed])
                              (destroy-entity ?item)
                              (begin-belief {@self provisions_shop ?shop})
                              (if (not (> (target {@self wealth}) 0.2))
                                  (then (crime-ledger-append @self (owner-of ?shop) steal steal _ _))))))))))))))
    ; The forage sitting IS a meal's hunger relief, whether or not the specific
    ; believed item still resolved (a stale belief - a sibling ate the loaf - must
    ; not re-arm the >1.3 gate and loop). Reduce unconditionally, like the old
    ; starving episodes did.
    (set-attr @self hunger (max 0 (- (attr @self hunger) 0.5)))
    (set-outcome {@self forage} succ)))
