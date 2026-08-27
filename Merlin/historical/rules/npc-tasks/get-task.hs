; ----------------------------------------------------------------------------
; get ?item - fetch a KNOWN, reachable item into hand: go to where it is, then take
; it. The general lawful fetch (retrieve an owned instance; the take leg of a steal).
; go + take are the primitives; get is their composition. Concludes when the take it
; caused has succeeded.
; ----------------------------------------------------------------------------

(npc-task {@self get ?item}:?get-rel
  (tar @excl object)
  (and
    (try
      (when (not (spatial ?item co-located @self)))
      (utility fallback)
      (effects (maintain-proposal {@self go (spatial ?item space)})))
    (try
      (when (spatial ?item co-located @self))
      (utility (above go))
      (effects (maintain-proposal {@self take ?item})))
    (try
      (when (any {@self take ?item /succ /caused_by ?get-rel}))
      (effects (set-outcome ?get-rel succ)))))
