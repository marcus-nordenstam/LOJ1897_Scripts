; ----------------------------------------------------------------------------
; steal ?kind - take an instance of ?kind WITHOUT paying, when unwatched. The crime
; twin of buy: same source-walk (to a shop that stocks the kind), but the grip is
; gated on (nobody-watching) - a snatch waits for the shelf to be unobserved - and no
; coin changes hands. The wronged party is the source's proprietor; the take concludes
; the theft and lands the crime-ledger row. The ended {@self steal ?kind} belief IS the
; deed memory (act/state doctrine) - no fiat record.
; ----------------------------------------------------------------------------

(include "../../macros/acquisition-macros.mc")

(npc-task {@self steal ?kind}:?steal-rel
  (track-skill-level [k illicit])
  (tar ?)
  (construed-act appropriation-act wrong-act) (theme thief-to) (contradicts property)
  (facets reportable_crime blackmailable)
  (and
    ; not at a source -> head to a shop @self KNOWS that stocks the kind.
    (try
      (role ?shop [k building shop] (select (score (near @self ?shop)) (policy roulette)))
      (when (and (empty (spatial @self hold ?kind))
                 (not (spatial @self building ?shop))))
      (utility fallback)
      (effects (maintain-proposal {@self enter ?shop})))
    ; knows no shop -> search the region for one, until the search proves there is none.
    (try
      (no-role [k building shop])
      (when (and (empty (spatial @self hold ?kind))
                 -{@self find-building [k building shop] ? /fail}
                 (current-region @self): ?rg))
      (utility fallback)
      (effects (maintain-proposal {@self find-building [k building shop] ?rg})))
    ; at a source, unwatched -> take a shelf item of the kind (the guarded snatch).
    (try
      (when (and (empty (spatial @self hold ?kind))
                 (is-a (spatial @self building) [k building shop])
                 (nobody-watching)))
      (effects
        (spatial @self building): ?shop
        (bind 0 ?found)
        (for-each ?room (spatial ?shop parts [k interior-space room] /env)
          (for-each ?item (spatial ?room contents ?kind /env) [/limit 1]
            (if (= ?found 0) (then (bind ?item ?loot) (bind 1 ?found)))))
        (if (= ?found 1)
            (then (maintain-proposal {@self take ?loot})))))
    ; concluded: the loot is in hand /caused_by this pursuit -> ledger + succ.
    (try
      (when (and (not (empty (spatial @self hold ?kind)))
                 {@self take ? /succ /caused_by ?steal-rel}
                 (is-a (spatial @self building) [k building shop])))
      (effects
        (spatial @self building): ?shop
        (crime-ledger-append @self (any {? own ?shop}).subject opportunist_theft steal ?kind @u)
        (set-outcome ?steal-rel /succ)))))
