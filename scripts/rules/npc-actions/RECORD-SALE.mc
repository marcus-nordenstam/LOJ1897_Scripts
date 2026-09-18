; ----------------------------------------------------------------------------
; record_sale ?dwell - the dumb ENV act of a purchase: transfer the record, nothing else.
; Re-points ?dwell's registry title-deed to name @self (the authoritative transfer that
; overrides the seller's now-stale {own} for every future deed reader) and pulls ?dwell's
; row off the for-sale register. All orchestration + the buyer's own beliefs live in the
; buy-home / founding task.
; ----------------------------------------------------------------------------

(npc-action {@self RECORD-SALE ?dwell}
  (track-skill-level [k accountancy])
  (duration 60)
  (effects
    (for-each ?deed (env-entities [k title-deed])
      (do
        (table-match (attr ?deed writing) building ?db)
        (if (= ?db ?dwell)
            (then
              (table-set ?deed owner @self)
              (break)))))
    (for-each ?listings (env-entities [k for-sale-listings])
      (table-remove ?listings building ?dwell))
    (set-outcome {@self RECORD-SALE ?dwell} /succ)))
