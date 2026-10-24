; ----------------------------------------------------------------------------
; time_macros.mc - clock and shift tunables.
; ----------------------------------------------------------------------------



; (work-starts-soon ?hours): NOT in the working hours now, and their next start is
; within this lead.
(define-macro work-lead-hours () 2.0)

; (time weekday) of a Sunday (1=Sun .. 7=Sat).
(define-macro sunday_weekday () 1)


; Elapsed days since the most recent ?what. The (none ..) gate answers "never done"
; FIRST, so the recall only runs when a record exists. The record is handed to
; (elapsed ..) WHOLE rather than projected: callers pass /ever patterns, which match
; a RUNNING act as readily as a concluded one, and an ongoing record's .end is @ongoing -
; abs-seconds reads that as the epoch, so every elapsed test against it passes. time-since
; takes the start of an ongoing event and the end of a concluded one, which is the answer
; either way: nothing is more recent than what is happening now.
(define-macro days-since-last (?what)
  (flip (none ?what)
        36500 ; 100 years in days - never done
        (elapsed /days (highest /end ?what))))

; The same count as a float, for a caller that weighs it.
(define-macro days-since-last-float (?what)
  (flip (none ?what) 36500.0 (elapsed /days /float (highest /end ?what))))


