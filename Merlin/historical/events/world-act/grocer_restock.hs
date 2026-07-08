; ----------------------------------------------------------------------------
; grocer_restock (world-act, zero-role): the DAILY shelf top-up. Grocers
; are the ONLY food seeders (ruling 14): founding stocks the shelves, the
; cooks' provisioning errands buy them down, and this pass re-seeds each
; grocer premises to the cap at the start of every simulated day (the
; deliveries a Victorian shop takes each morning). WHICH premises get
; stocked is decided here (the public incorporation register names each
; org's building); the spawn itself is the sanctioned world-gen substrate
; behind (seed-food-stock ...) - an idempotent count-then-spawn, so
; restocking a full shelf is a no-op.
;
; The cap (200) is a TOWN-DAY of provisions: a food prop is a PERSON-DAY
; (one per diner per home supper), so the shelf must carry roughly the
; population between daily restocks - the 10yr validation showed a
; monthly 80 fed half the town per simulated day and the poor stole the
; difference (~560 shelf thefts/yr). The substrate spreads the spawns
; round-robin across the shop's rooms to stay under the per-room
; contents cap. Matches k_grocer_food_stock (the founding-time seed);
; keep them in step.
; ----------------------------------------------------------------------------

(hsim-world-event grocer_restock
  (schedule (daily))

  (effects
    (for-each ?art (documents [k articles_of_incorporation])
      (do
        (read-doc-record [k articles_of_incorporation] ?art (kind ?ok) (building ?b))
        (if (and (is-a ?ok [k org grocer]) (is-entity ?b))
            (seed-food-stock ?b /count 200))))
    ))
