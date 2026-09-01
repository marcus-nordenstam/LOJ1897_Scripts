; ----------------------------------------------------------------------------
; money (npc-think lane) - physical-cash housekeeping.
;
;   seed_coin_pile : an NPC that owns no coin pile yet PROPOSES seeding one (the
;                    env writes live in the SEED-COINS action - a think must not
;                    mutate the world). The negative own-gate is a ROLE filter, so
;                    a write under `own` wakes it; once the pile is owned it closes.
;                    Self-heals immigrants + the newly-adult. Homeless NPCs (no
;                    home belief) wait until housed.
;   accrue_savings : once a year (December, adults) the NPC's coin pile is credited
;                    with (accrual-net). The pile + the amount are resolved HERE
;                    (a think may read beliefs) and handed to the ACCRUE-SAVINGS
;                    action on its pattern; the action only writes the env pile.
;                    The same think mints the derived {@self wealth ?} off the
;                    PROJECTED post-credit balance (annual, post-accrual - the shape
;                    the old C++ classify_wealth had), so no fragile re-arm on a
;                    perceived count change is needed. economic-situation.hs bands it.
; ----------------------------------------------------------------------------

(include "../../../macros/money-macros.mc")

(npc-think seed_coin_pile
  (cooldown 1 m)
  (role @self -{@self own [k pile]})
  (role ?home {@self home ?home})
  (utility duty)
  (effects (maintain-proposal {@self SEED-COINS ?home})))

(npc-think accrue_savings
  (cooldown 1 m)
  (role ?pile {@self coin-pile ?pile})
  (when (and (in-month 12)
             (>= (years-old @self) 15)))
  (utility duty)
  (effects
    (bind (accrual-net @self) ?net)
    (maintain-proposal {@self ACCRUE-SAVINGS ?pile ?net})
    (begin-belief {@self wealth (wealth-from @self (+ (coin-balance @self) ?net))})))
