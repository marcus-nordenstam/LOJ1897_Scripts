; ----------------------------------------------------------------------------
; get ?item - fetch a KNOWN, reachable item into hand: go to where it is, then take
; it. The general lawful fetch (retrieve an owned instance; the take leg of a steal).
; go + take are the primitives; get is their composition. Concludes when the take it
; caused has succeeded.
; ----------------------------------------------------------------------------

(task {@self get ?item}:?get
  (tar @excl [k object] @object)
  (and
    (try
      (when (not (spatial ?item co-located @self)))
      (declare-utility fallback)
      (effects (maintain-proposal {@self go-to ?item})))
    (try
      (when (spatial ?item co-located @self))
      (declare-utility (above go-to))
      (effects (maintain-proposal {@self take ?item})))
    (try
      (when {@self take ?item /succ /caused_by ?get})
      (effects (set-outcome ?get /succ)))))
