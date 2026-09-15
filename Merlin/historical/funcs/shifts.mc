; ----------------------------------------------------------------------------
; draw-shift - one of the authored shifts of ?job-kind (the `default` week when the kind
; has none), drawn at random. A ledger line is established with its shift, and the offer
; letter quotes it; stamp-shift-hours (macros/founding.mc) turns it into day-hours beliefs.
; A func, not a macro: its rows and bounds live in its own slots, not the caller's.
; ----------------------------------------------------------------------------

(define-func draw-shift (?job-kind)
  (if (table-match occupation_shifts job ?job-kind)
      (then ?job-kind)
      (else default)): ?key
  (bind 0 ?top)
  (for-each-row occupation_shifts [/job ?j] [/shift-id ?sid]
    (if (and (= ?j ?key) (> ?sid ?top))
        (then (bind ?sid ?top))))
  (random-int 0 ?top))
