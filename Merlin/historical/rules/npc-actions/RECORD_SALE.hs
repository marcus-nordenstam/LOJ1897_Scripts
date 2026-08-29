; ----------------------------------------------------------------------------
; record_sale ?dwell - the dumb ENV act of a home purchase: transfer the record,
; nothing else. Re-points the dwelling's registry title_deed to name @self (the
; authoritative transfer that overrides the seller's now-stale {own} for every
; future deed reader) and pulls the sold dwelling's for_sale listing from the
; register. All orchestration + the buyer's own beliefs live in the buy_home task.
; ----------------------------------------------------------------------------

(npc-action {@self RECORD_SALE ?dwell}
  (duration 60)
  (effects
    (for-each ?deed (env-entities [k title_deed])
      (do
        (table-match (attr ?deed writing) building ?db)
        (if (= ?db ?dwell)
            (then
              (table-set ?deed owner @self)
              (break)))))
    (for-each ?listing (env-entities [k for_sale_listing])
      (do (if (= (attr ?listing address) ?dwell)
              (then (destroy-entity ?listing) (break)))))
    (set-outcome {@self RECORD_SALE ?dwell} succ)))
