; ----------------------------------------------------------------------------
; record_sale ?dwell - the dumb ENV act of a purchase: transfer the record, nothing else.
; Re-points ?dwell's registry title_deed to name @self (the authoritative transfer that
; overrides the seller's now-stale {own} for every future deed reader) and pulls ?dwell's
; row off the for-sale register. All orchestration + the buyer's own beliefs live in the
; buy_home / founding task.
; ----------------------------------------------------------------------------

(npc-action {@self RECORD_SALE ?dwell}
  (track-skill-level [k accountancy])
  (duration 60)
  (effects
    (for-each ?deed (env-entities [k title_deed])
      (do
        (table-match (attr ?deed writing) building ?db)
        (if (= ?db ?dwell)
            (then
              (table-set ?deed owner @self)
              (break)))))
    (for-each ?listings (env-entities [k for_sale_listings])
      (table-remove ?listings building ?dwell))
    (set-outcome {@self RECORD_SALE ?dwell} /succ)))
