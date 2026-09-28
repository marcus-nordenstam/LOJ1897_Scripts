; ----------------------------------------------------------------------------
; eat ?meal ?place - the unified meal task (breakfast / lunch / supper, incl. eating out).
; The act-belief {@self eat [k <meal>] <place>} IS the episodic meal memory. Its three
; INCLUSIVE tries co-fire at the table:
;   take_meal   - propose the EAT action (the physical eating); its ended outcome is
;                 copied onto the eat task at the cease (bottom-up conclusion). A home
;                 supper resolves a real food prop to destroy; otherwise abstract (?food 0).
;   table_hours - now and then re-air the house's mealtimes to everyone at the home table.
;   table_talk  - turn to one co-present diner and air one untold piece of my own news.
; ----------------------------------------------------------------------------

(include "../../macros/collection-macros.mc")

(npc-task {@self eat ?meal ?place}:?eat
  (tar [k meal])
  (aux [k structure|space] @object)
  (and
    (try
      (utility (switch (kind ?meal)
                 (on [k breakfast] 820)
                 (on [k lunch]     850)
                 (else             780)))
      (effects
        (bind 0 ?food)
        ; A home supper eats one loaf off the kitchen larder PILE (the diner
        ; stands in the home); ?food = that pile, handed to EAT which
        ; decrements it. Breakfast / lunch / a bought-out supper stay abstract.
        (if (and (is-a ?meal [k supper])
                 {@self home ?place})
            (then
              (bind 0 ?et_kitchen)
              (spatial ?place room [k kitchen]): ?et_kitchen
              (if ?et_kitchen
                  (then
                    (bind 0 ?et_pile)
                    (for-each ?pile_cand (spatial ?et_kitchen contents [k pile] /env)
                      (if (attr-is ?pile_cand content-kind [k food])
                          (then (bind ?pile_cand ?et_pile))))
                    (if (and ?et_pile (> (attr ?et_pile count) 0))
                        (then (bind ?et_pile ?food)))))))
        (maintain-proposal {@self EAT ?food 0}))
      (when-unsupported-effects
        (caused-by {@self EAT ? ? /past} ?eat): ?EAT
        (if ?EAT (then (set-outcome ?eat (outcome ?EAT))))))
    (try
      (role ?home {@self home ?home}
        (role @self -{@self SAY ? ? /succ /caused_by ?eat}
          (when (and (= ?place ?home) (latch-eval (chance 0.25))))
          (effects
            (for-each ?breakfast-hour (every {?home breakfast-hour ?})
                (bind ?breakfast-hour.target ?b)
                (for-each ?lunch-hour (every {?home lunch-hour ?})
                    (bind ?lunch-hour.target ?l)
                    (for-each ?supper-hour (every {?home supper-hour ?})
                        (bind ?supper-hour.target ?s)
                        (maintain-proposal
                          {@self SAY (utterable-msg {?home breakfast-hour ?b}
                                                    {?home lunch-hour ?l}
                                                    {?home supper-hour ?s}) _}))))))))
    (try
      (rng-stream behaviour)
      (role ?diner {?diner isa [k human], condition [k alive]}
                   (spatial ?diner co-located @self)
                   (select (score 1) (policy roulette))
        (effects
          (for-each ?belief (every {@self spouse|fiancee|child|job|interest|birthplace|home|mother|father|sibling|friend|nationality|calling|value|life-aim ?})
            (do
              (utterable-msg ?belief): ?msg
              (if -{@self SAY ?msg ?diner}
                  (then (maintain-proposal {@self SAY ?msg ?diner}) (break))))))))))
