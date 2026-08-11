; ----------------------------------------------------------------------------
; meals - the npc-ACT half of the UNIFIED eat lane (the desires live in
; npc-think/meals.hs). This file holds the meals-local define-macros
; (larder_target / carry_cap) and the acts: dwell_action, eat_action, provision_action,
; forage_action.
;
; ONE act-goal serves every routine meal: {@self eat [k <meal>] <place>} -
; target = the meal occasion (breakfast | lunch | supper), aux = the place
; eaten at. A desire mints it in its window; the <place> drives a leaf-first
; approach (eat_go, like drink/worship); at the place it promotes to the shared
; eat_action. The begun-then-ended act-belief IS the meal memory (interval = the
; sitting) - there is no separate `dine` record.
;
; TABLE TALK is its OWN role-bearing event (npc-think/intra-day/table_talk_think.hs)
; so it can bind the diner it addresses and dedup per-listener; eat_action keeps only
; the food + the house-hours re-air. Only a HOME SUPPER consumes (one person-day
; food prop per diner); breakfast / lunch / eating-out are abstract. Being under
; attack gates every lane out (the fight lane owns the moment).
; ----------------------------------------------------------------------------

; ---- the act: one body for every meal, differentiated by the meal-kind -------

; The eat goal, at its place, is the leaf and promotes here. The begun-then-ended
; {@self eat [k <meal>] <place>} act-belief IS the meal memory.
; INGEST - the physical eating. A pure ACTION: it reads only its own pattern
; (?meal for the duration + hunger profile, ?food for what to destroy) and the
; hunger ATTR it updates. All the reasoning (which food, whose table) happened in
; the eat task's take_meal rung, which hands ?food (a believed loaf, or 0 for an
; abstract meal). ONE action serves every meal - the eat TASK differentiates them.
(npc-action {@self ingest ?meal ?food}
  ; supper is the hour-long family meal; lunch 40; breakfast 30.
  (duration (if (is-a ?meal [k supper]) (then 60)
             (else (if (is-a ?meal [k lunch]) (then 40) (else 30)))))
  (effects
    ; consume the passed loaf (a home supper); 0 for an abstract meal.
    (if ?food
        (then (realize-destroyed ?food [k condition consumed])
              (destroy-entity ?food)))
    ; HUNGER: a full supper resets; a lighter meal takes the edge off.
    (if (is-a ?meal [k supper])
        (then (set-attr @self hunger 0))
        (else (set-attr @self hunger (max 0 (- (attr @self hunger) 0.35)))))
    (set-outcome {@self ingest ?meal ?food} succ)))

; (provision_action - the counter stop - lives in npc-actions/provision_action.hs;
; the general put-down completion in npc-actions/bring_action.hs.)

; The consume act: destroy ONE thing eaten + relieve hunger. Generic - the WHICH
; (carried / home pantry / a shop's stock) is decided think-side (forage_at_source
; in meals_think.hs); the act receives the chosen ?item + the wronged ?owner off
; its pattern and does no reasoning. ?owner is 0 when the food is the eater's own;
; a non-zero ?owner is a STOLEN mouthful and lands on the crime ledger.
(npc-action {@self consume ?item ?owner}
  (duration 10)
  (effects
    (realize-destroyed ?item [k condition consumed])
    (destroy-entity ?item)
    (set-attr @self hunger (max 0 (- (attr @self hunger) 0.5)))
    (if ?owner
        (then (crime-ledger-append @self ?owner steal steal _ _)))
    (set-outcome {@self consume ?item ?owner} succ)))
