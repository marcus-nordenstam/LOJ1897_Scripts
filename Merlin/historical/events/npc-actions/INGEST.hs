; ----------------------------------------------------------------------------
; ingest - the npc-ACT half of the UNIFIED eat lane (the desires live in
; npc-think/meals.hs). The physical eating.
;
; ONE act-goal serves every routine meal: {@self eat [k <meal>] <place>} -
; target = the meal occasion (breakfast | lunch | supper), aux = the place
; eaten at. A desire mints it in its window; the <place> drives a leaf-first
; approach (eat_go, like drink/worship); at the place it promotes to the shared
; INGEST act. The begun-then-ended act-belief IS the meal memory (interval = the
; sitting) - there is no separate `dine` record.
;
; TABLE TALK is its OWN role-bearing event (npc-think/intra-day/table_talk_think.hs)
; so it can bind the diner it addresses and dedup per-listener; INGEST keeps only
; the food + the house-hours re-air. Only a HOME SUPPER consumes (one person-day
; food prop per diner); breakfast / lunch / eating-out are abstract. Being under
; attack gates every lane out (the fight lane owns the moment).
; ----------------------------------------------------------------------------

; The eat goal, at its place, is the leaf and promotes here. The begun-then-ended
; {@self eat [k <meal>] <place>} act-belief IS the meal memory.
; INGEST - the physical eating. A pure ACTION: it reads only its own pattern
; (?meal for the duration + hunger profile, ?food for what to destroy) and the
; hunger ATTR it updates. All the reasoning (which food, whose table) happened in
; the eat task's take_meal rung, which hands ?food (a believed loaf, or 0 for an
; abstract meal). ONE action serves every meal - the eat TASK differentiates them.
(npc-action {@self INGEST ?meal ?food}
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
    (set-outcome {@self INGEST ?meal ?food} succ)))

; (PROVISION.hs - the counter stop - lives in npc-actions/PROVISION.hs;
; the general put-down completion in npc-actions/BRING.hs.)
