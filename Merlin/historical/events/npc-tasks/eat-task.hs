; ----------------------------------------------------------------------------
; eat ?meal ?place - the unified meal task (breakfast / lunch / supper, incl. eating out).
; The act-belief {@self eat [k <meal>] <place>} IS the episodic meal memory. Its three
; INCLUSIVE tries co-fire at the table:
;   take_meal   - propose the INGEST action (the physical eating); its ended outcome is
;                 copied onto the eat task at the cease (bottom-up conclusion). A home
;                 supper resolves a real food prop to destroy; otherwise abstract (?food 0).
;   table_hours - now and then re-air the house's mealtimes to everyone at the home table.
;   table_talk  - turn to one co-present diner and air one untold piece of my own news.
; ----------------------------------------------------------------------------

(npc-task {@self eat ?meal ?place}:?e-rel
  (tar meal)
  (aux structure|space)
  (and
    (try
      (utility (if (is-a ?meal [k breakfast]) (then 820)
                (else (if (is-a ?meal [k lunch]) (then 850) (else 780)))))
      (effects
        (bind 0 ?food)
        (if (and (is-a ?meal [k supper])
                 (any {@self home ?place} (out int))
                 (believed-located [k food] ?place))
            (then (believed-located [k food] ?place): ?food))
        (maintain-proposal {@self INGEST ?meal ?food}))
      (cease-effects
        (caused-by {@self INGEST ?meal /past} ?e-rel): ?rec-rel
        (if ?rec-rel (then (set-outcome ?e-rel (outcome ?rec-rel))))))
    (try
      (role ?home {@self home ?home})
      (when (and (= ?place ?home) (chance 0.25)))
      (effects
        (for-each ?bb-rel (every {?home breakfast_hour ?})
            ?bb-rel.target: ?b
            (for-each ?lb-rel (every {?home lunch_hour ?})
                ?lb-rel.target: ?l
                (for-each ?sb-rel (every {?home supper_hour ?})
                    ?sb-rel.target: ?s
                    (tell (utterable-msg {?home breakfast_hour ?b}
                                         {?home lunch_hour ?l}
                                         {?home supper_hour ?s})))))))
    (try
      (rng-stream behaviour)
      (role ?diner (any_human ?diner)
                   (co-present ?diner @self)
                   (select (score 1) (policy roulette)))
      (when (or (in-building @self ?place) (at_location @self ?place)))
      (effects
        (for-each ?belief-rel (every {@self spouse|fiancee|child|job|interest|birthplace|home|mother|father|sibling|friend|nationality|calling|value|life_aim ?})
          (do
            (utterable-msg ?belief-rel): ?msg
            (if (none {@self SAY ?msg ?diner})
                (then (maintain-proposal {@self SAY ?msg ?diner}) (break)))))))))
