; ----------------------------------------------------------------------------
; eat ?meal ?place - the unified meal task (breakfast / lunch / supper, incl. eating out),
; proposed by the meal drivers (drivers/meals-driver.mc). The act-belief
; {@self eat [k <meal>] <place>} IS the episodic meal memory. Away from the place he walks
; there, while he can pay for it; at the place:
;   serve       - a portion served off the place's larder (a home's kitchen pile, a pub's
;                 bar-room pile), bought first into its till where the meal is bought out;
;   pack lunch  - at breakfast a man with a job serves a second portion and stows it, his
;                 lunch at work;
;   eat         - the portion in his hand, or at lunch away from home the one he carried, is
;                 eaten (EAT); its outcome is copied onto the eat task (bottom-up conclusion);
;   table_hours - now and then re-air the house's mealtimes to everyone at the home table.
; ----------------------------------------------------------------------------

(include "../../macros/collection-macros.mc")

(define-macro meal-utility (?meal)
  (switch (kind ?meal)
    (on [k breakfast] 820)
    (on [k lunch]     850)
    (else             780)))

(task {@self eat ?meal ?place}:?eat
  (belief-timeout 1 h)
  (construed-act sensual-act social-act)
  (tar [k meal])
  (aux [k structure|space] @object)
  (and
    (try
      (when (and (not (at-meal-place ?place))
                 (eat-affordable ?meal ?place)
                 (meal-to-be-had ?meal ?place)))
      (effects (maintain-proposal {@self enter-room ?place})))
    ; His meal: the portion to hand, eaten.
    (try
      (when (and (at-meal-place ?place)
                 (substantial (meal-portion ?meal ?place))
                 (not (packs-lunch ?meal))))
      (bind (meal-portion ?meal ?place) ?food)
      (declare-utility (meal-utility ?meal))
      (effects (maintain-proposal {@self EAT ?food 0}))
      (when-unsupported-effects
        (caused-by {@self EAT ? ? /past} ?eat): ?EAT
        (if ?EAT (then (set-outcome ?eat (outcome ?EAT))))))
    ; At breakfast the portion to hand is his lunch to take, stowed.
    (try
      (when (and (at-meal-place ?place)
                 (substantial (meal-portion ?meal ?place))
                 (packs-lunch ?meal)))
      (bind (meal-portion ?meal ?place) ?lunch)
      (declare-utility (meal-utility ?meal))
      (effects (maintain-proposal {@self STOW ?lunch})))
    (sequence
      (when (and (at-meal-place ?place) (unsubstantial (meal-portion ?meal ?place))))
      (declare-utility (meal-utility ?meal))
      (stage
        (bind (meal-till ?place) ?till)
        (bind (meal-larder-room ?place) ?room)
        (effects
          (if (and (meal-unpaid ?meal ?place ?eat) (substantial ?till) (not (spatial @self can-reach ?till)))
              (then
                (if (not (spatial @self space ?room))
                    (then (maintain-proposal {@self enter-room ?room}))
                    (else (bind (claim (stand-spot-by ?till)) ?spot)
                          (if (is-spot ?spot) (then (maintain-proposal {@self go-to ?spot})))))))))
      (stage
        (effects
          (if (and (meal-unpaid ?meal ?place ?eat) (unsubstantial (coin-pile-in-hand @self)))
              (then (maintain-proposal {@self unpocket-coins (price ?meal ?place)})))))
      (stage
        (bind (meal-till ?place) ?till)
        (bind (coin-pile-in-hand @self) ?counted)
        (effects
          (if (and (meal-unpaid ?meal ?place ?eat) (substantial ?counted) (substantial ?till))
              (then (maintain-proposal {@self PILE-TRANSFER ?counted ?till})))))
      (stage
        (role ?larder [k pile] {?larder content-kind [k food]} {?larder count >0}
                      (= (spatial ?larder space) (meal-larder-room ?place))
                      (select (policy first-match))
          (bind (meal-larder-room ?place) ?room)
          (effects
            (if (not (spatial @self can-reach ?larder))
                (then
                  (if (not (spatial @self space ?room))
                      (then (maintain-proposal {@self enter-room ?room}))
                      (else (bind (claim (stand-spot-by ?larder)) ?spot)
                            (if (is-spot ?spot) (then (maintain-proposal {@self go-to ?spot}))))))))))
      (stage
        (effects
          (if (substantial (any {?larder count >0}))
              (then (maintain-proposal {@self SERVE ?larder (free-hand)}))))))
    (try
      (role ?home {@self home ?home}
        (belief -{@self SAY ? ? /succ /caused_by ?eat}
          (when (and (= ?place ?home) (at-meal-place ?place) (latch-eval (chance 0.25))))
          (effects
            (for-each ?breakfast-hour (every {?home breakfast-hour ?})
                (bind ?breakfast-hour.target ?b)
                (for-each ?lunch-hour (every {?home lunch-hour ?})
                    (bind ?lunch-hour.target ?l)
                    (for-each ?supper-hour (every {?home supper-hour ?})
                        (bind ?supper-hour.target ?s)
                        (maintain-intent
                          {@self intent {@self SAY (msg /utterable [] {?home breakfast-hour ?b}
                                                    {?home lunch-hour ?l}
                                                    {?home supper-hour ?s}) _}}))))))))))
