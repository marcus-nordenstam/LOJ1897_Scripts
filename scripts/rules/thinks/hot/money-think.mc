; ----------------------------------------------------------------------------
; money (think) - physical-cash housekeeping.
;
;   seed-coin-pile : an NPC that owns no coin pile yet PROPOSES seeding one (the
;                    env writes live in the SEED-COINS action - a think must not
;                    mutate the world). The negative own-gate is a ROLE filter, so
;                    a write under `own` wakes it; once the pile is owned it closes.
;                    Self-heals immigrants + the newly-adult. Homeless NPCs (no
;                    home belief) wait until housed.
;   accrue-savings : once a year (December, adults) the NPC's coin pile is credited
;                    with (accrual-net). The pile + the amount are resolved HERE
;                    (a think may read beliefs) and handed to the ACCRUE-SAVINGS
;                    action on its pattern; the action only writes the env pile.
;                    The same think mints the derived {@self wealth ?} off the
;                    PROJECTED post-credit balance (annual, post-accrual - the shape
;                    the old C++ classify_wealth had), so no fragile re-arm on a
;                    perceived count change is needed. classify-economic-situation.mc bands it.
; ----------------------------------------------------------------------------

(include "../../../macros/money-macros.mc")

(think seed-coin-pile
  (cooldown 1 m try-until-succ)
  (role @self -{@self own [k pile]}
    (role ?home {@self home ?home}
      (declare-utility duty)
      (effects (maintain-proposal {@self SEED-COINS ?home})))))

(think accrue-savings
  (cooldown 1 m try-until-succ)
  (role @self {@self age ?age}
    (role ?pile {@self coin-pile ?pile}
      (when (and (in-month 12)
                 (>= ?age 15)))
      (declare-utility duty)
      (effects
        (any {@self job.salary ?salary=0})
        (any {@self coin-pile.count ?coins=0})
        (any {@self home ?home=@nothing})
        (bind (+ ?salary
                 (if (> (count (every {@self own [k building]})) 0) (then (accrual_owner_bonus)) (else 0))) ?net)
        (maintain-proposal {@self ACCRUE-SAVINGS ?pile ?net})
        (begin-belief {@self wealth (/ (clamp (+ /float (/ /float (+ ?coins ?net) (wealth_coin_div)) (if (substantial ?home) (then (switch (kind ?home)
                                                                                                        (on [k manor]                40)
                                                                                                        (on [k townhouse]            30)
                                                                                                        (on [k farmhouse]            18)
                                                                                                        (on [k residential-building]  0)
                                                                                                        (else                        25)))
                                                                                                (else 0))) 0.0 100.0) 100.0)})))))
