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
    (for-each ?deed (documents [k title_deed])
      (do
        (read-doc-record [k title_deed] ?deed (building ?db))
        (if (= ?db ?dwell)
            (then
              (update-doc-record [k title_deed] ?deed (owner @self))
              (break)))))
    (for-each ?listing (documents [k for_sale_listing])
      (do (if (= (attr ?listing address) ?dwell)
              (then (destroy-entity ?listing) (break)))))
    (set-outcome {@self RECORD_SALE ?dwell} succ)))
