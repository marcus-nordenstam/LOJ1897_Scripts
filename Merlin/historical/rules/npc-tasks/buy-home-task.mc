; ----------------------------------------------------------------------------
; buy_home ?dwell - the BUYER's purchase task (the demand side promotes it from
; the {@self acquire} desire once choose_home has picked a dwelling; see
; buy_home_think.hs). Buying a home is a COMPLEX task: it ORCHESTRATES the sale and
; carries the buyer's own thinking (the ownership + residence beliefs he takes on),
; delegating the single authoritative ENV record-change to the simple RECORD_SALE
; action. @self NEVER touches the seller's mind - the deed the act re-points is the
; public record every future reader sees (most for-sale supply is dead / emigrated
; owners who hold no mind at all).
;
;   settle   : still for sale (per the listing @self READ) and not yet recorded ->
;              propose the RECORD_SALE act.
;   take_up  : the record transferred -> mint @self's {own} + {home} (@excl, leaves
;              the natal home) + {occupant}, drop the read-in for-sale belief, conclude.
;   lost     : a rival closed first (no longer for sale, never settled) -> abandon.
; ----------------------------------------------------------------------------

(npc-task {@self buy_home ?dwell}:?bh-rel
  (tar @excl building)
  (and
    (try
      (when (and {?dwell availability [k for-sale]}
                 -{@self RECORD_SALE ?dwell /succ}))
      (utility errand)
      (effects (debug-print "BH_SETTLE")
               (maintain-proposal {@self RECORD_SALE ?dwell})))
    (try
      (when {@self RECORD_SALE ?dwell /succ})
      (effects
        (debug-print "BH_TAKEUP")
        (begin-belief {@self own ?dwell})
        (begin-belief {@self home ?dwell})
        (begin-belief {?dwell occupant @self})
        (end-belief {?dwell availability [k for-sale]})
        (set-outcome ?bh-rel /succ)))
    (try
      (when (and -{?dwell availability [k for-sale]}
                 -{@self RECORD_SALE ?dwell /succ}))
      (effects (debug-print "BH_LOST") (set-outcome ?bh-rel /fail)))))
