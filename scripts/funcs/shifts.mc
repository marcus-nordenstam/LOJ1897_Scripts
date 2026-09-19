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

; ----------------------------------------------------------------------------
; on-shift - the shift is on, or it is about to be: the condition the work task and the
; recruit-staff round each run under, read by their (when ..) and inverted in their
; (cease ..). The starts-soon lead is part of it because a duty is taken up while the man
; is still at home.
; ----------------------------------------------------------------------------

(define-func on-shift (?start ?end)
  (or (in-work-hours ?start ?end) (work-starts-soon ?start ?end)))
