; ----------------------------------------------------------------------------
; eat ?meal ?place - the unified meal task (breakfast / lunch / supper, incl. eating out),
; proposed by the meal drivers (drivers/meals-driver.mc). The act-belief
; {@self eat [k <meal>] <place>} IS the episodic meal memory. Away from the place he walks
; there, while he can pay for it; at the place three INCLUSIVE tries co-fire at the table:
;   take_meal   - propose the EAT action (the physical eating); its ended outcome is
;                 copied onto the eat task at the cease (bottom-up conclusion). A home
;                 supper resolves a real food prop to destroy; otherwise abstract (?food 0).
;   table_hours - now and then re-air the house's mealtimes to everyone at the home table.
;   table_talk  - turn to one co-present diner and air one untold piece of my own news.
; ----------------------------------------------------------------------------

(include "../../macros/collection-macros.mc")

(define-macro meal-utility (?meal)
  (switch (kind ?meal)
    (on [k breakfast] 820)
    (on [k lunch]     850)
    (else             780)))

(task {@self eat ?meal ?place}:?eat
  (tar [k meal])
  (aux [k structure|space] @object)
  (and
    (try
      (when (and (not (at-meal-place ?place))
                 (eat-affordable ?meal ?place)))
      (effects (maintain-proposal {@self go-to ?place})))
    ; A home supper eats one loaf off a kitchen larder PILE he knows of, handed to EAT which
    ; decrements it; any other meal, or a larder he has not seen, stays abstract.
    (try
      (role @self {@self home ?place}
        (role ?food [k pile] {?food content-kind [k food]} {?food count >0}
                    (= (spatial ?food space) (spatial ?place room [k kitchen]))
                    (select (policy first-match))
          (when (and (at-meal-place ?place) (is-a ?meal [k supper])))
          (declare-utility (meal-utility ?meal))
          (effects (maintain-proposal {@self EAT ?food 0}))
          (when-unsupported-effects
            (caused-by {@self EAT ? ? /past} ?eat): ?EAT
            (if ?EAT (then (set-outcome ?eat (outcome ?EAT))))))))
    (try
      (no-role [k pile] {?norole content-kind [k food]} {?norole count >0}
                        (= (spatial ?norole space) (spatial ?place room [k kitchen]))
                        {@self home ?place}
                        (is-a ?meal [k supper]))
      (when (at-meal-place ?place))
      (declare-utility (meal-utility ?meal))
      (effects (maintain-proposal {@self EAT 0 0}))
      (when-unsupported-effects
        (caused-by {@self EAT ? ? /past} ?eat): ?EAT
        (if ?EAT (then (set-outcome ?eat (outcome ?EAT))))))
    (try
      (role ?home {@self home ?home}
        (role @self -{@self tell ? ? /succ /caused_by ?eat}
          (when (and (= ?place ?home) (at-meal-place ?place) (latch-eval (chance 0.25))))
          (effects
            (for-each ?breakfast-hour (every {?home breakfast-hour ?})
                (bind ?breakfast-hour.target ?b)
                (for-each ?lunch-hour (every {?home lunch-hour ?})
                    (bind ?lunch-hour.target ?l)
                    (for-each ?supper-hour (every {?home supper-hour ?})
                        (bind ?supper-hour.target ?s)
                        (maintain-proposal
                          {@self tell (utterable-msg [] {?home breakfast-hour ?b}
                                                    {?home lunch-hour ?l}
                                                    {?home supper-hour ?s}) _}))))))))
    (try
      (rng-stream behaviour)
      (role ?diner {?diner isa [k human], condition [k alive]}
                   (spatial ?diner co-located @self)
                   -{@self tell ? ?diner /succ /caused_by ?eat}
                   (select (score 1) (policy roulette))
        (when (at-meal-place ?place))
        (effects
          (for-each ?belief (every {@self spouse|fiancee|child|job|interest|birthplace|home|mother|father|sibling|friend|nationality|calling|value|life-aim ?})
            (do
              (utterable-msg [] ?belief): ?msg
              (if -{@self tell ?msg ?diner /succ}
                  (then (maintain-proposal {@self tell ?msg ?diner}) (break))))))))))
