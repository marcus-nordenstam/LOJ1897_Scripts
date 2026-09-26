; DORMANT - this lane never ran; revived on the form deeds / articles with its own gauntlet.
;; ----------------------------------------------------------------------------
;; record_sale ?dwell - the dumb ENV act of a purchase: transfer the record, nothing else.
;; Re-points ?dwell's registry title-deed to name @self (the authoritative transfer that
;; overrides the seller's now-stale {own} for every future deed reader) and pulls ?dwell's
;; row off the for-sale register. All orchestration + the buyer's own beliefs live in the
;; buy-home / founding task.
;; ----------------------------------------------------------------------------

;(npc-action {@self RECORD-SALE ?dwell}
;  (motor body legs)
;  (track-skill-level [k accountancy])
;  (duration (seconds 60 min))
;  (effects
;    (claim-deed ?dwell)
;    (delist ?dwell)
;    (set-outcome {@self RECORD-SALE ?dwell} /succ)))
