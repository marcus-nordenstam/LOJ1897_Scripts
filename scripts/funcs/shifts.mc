; ----------------------------------------------------------------------------
; draw-shift - one of the authored shifts of ?job-kind (the [k job] week when the kind
; has none), drawn at random. A ledger line is established with its shift, and the offer
; letter quotes it; stamp-shift-hours (funcs/founding.mc) turns it into working-hours beliefs.
; A func, not a macro: its rows and bounds live in its own slots, not the caller's.
; ----------------------------------------------------------------------------

(define-func draw-shift (?job-kind)
  (flip (table-match occupation_shifts job ?job-kind) ?job-kind [k job]): ?key
  (bind 0 ?top)
  (for-each-row occupation_shifts [/job ?j] [/shift-id ?sid]
    (if (and (= ?j ?key) (> ?sid ?top))
        (then (bind ?sid ?top))))
  (random-int 0 ?top))

; ----------------------------------------------------------------------------
; on-shift - the working hours ?hours are on, or about to be: the condition the work task
; and the recruit-staff round each run under, read by their (when ..) and inverted in their
; (cease ..). The starts-soon lead is part of it because a duty is taken up while the man
; is still at home.
; ----------------------------------------------------------------------------

(define-func on-shift (?hours)
  (or (within (time seconds) ?hours) (work-starts-soon ?hours)))

; current-shift - the one of ?job's working hours that is on, or about to be; @false when none
; is, so a (:) bind of it ends the rung.
(define-func current-shift (?job)
  (bind @nothing ?cs-hours)
  (for-each ?wh (every {?job working-hours ?})
    (bind ?wh.target ?cs-each)
    (if (on-shift ?cs-each)
        (then (bind ?cs-each ?cs-hours))))
  (flip (substantial ?cs-hours) ?cs-hours @false))

; shift-end-hour - the hour the occurrence of ?hours now on, or next, ends at: the hour after
; its last minute, the boundary a post-stay DWELL aims at.
(define-func shift-end-hour (?hours)
  (+ (hour (next-end ?hours (time seconds))) 1))

; set-shift-end-alarm - wake @self the second after the occurrence of ?hours now on, or next,
; ends: nothing else re-tests a shift reader's on-shift gate when the shift ends.
(define-func set-shift-end-alarm (?hours)
  (set-think-alarm (+ (next-end ?hours (time seconds)) 1)))
