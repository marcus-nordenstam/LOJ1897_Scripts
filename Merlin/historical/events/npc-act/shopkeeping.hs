; ----------------------------------------------------------------------------
; shopkeeping (npc-act) - the stocktake round.
;
; The clerk, at his counter with the standing stocktake goal, walks the
; premises for half an hour validating what he believes is on the shelves
; against what actually is (take-stock-of, stocktake_macros.hs): a
; sold / stolen / eaten item's whereabouts belief ends at the gap where it
; used to sit. Utility 82: a shade over the work shift (80), so the round
; happens on arrival and the counter work resumes after.
; ----------------------------------------------------------------------------

(hsim-npc-behaviour stocktake_round
  (short-term-think)
  (goal {@self stocktake})
  (when (and (not (under-attack))
             (bind {@self employer ?org})
             (bind {?org workplace ?wp})
             (at-place ?wp)))
  (utility 82)
  (effects (begin-act {@self stocktake} 30 stocktake_done)))

(hsim-npc-behaviour stocktake_done
  (on-completion)
  (effects
    (bind (current-building @self) ?shop)
    (if (is-entity ?shop)
        (for-each ?room (attr-values ?shop parts [k interior_space room])
          (take-stock-of ?room [k food])))
    (end-goal {@self stocktake})))
