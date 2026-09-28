; ----------------------------------------------------------------------------
; time_macros.mc - shift / clock arithmetic, pure .mc over (time hour)/(time minute).
;
; These fold the old C++ shift ops (in-work-hours / work-starts-soon /
; minutes-until-shift-end + the t_hse_engine helper methods) into macros. The
; only irreducible pieces are the clock sources (time hour) / (time minute); every
; window rule + tuning constant (the 120-minute lead, the 1440 min/day wrap) is
; authored HERE, not baked in C++.
;
; ?start / ?end are shift hours (0..23); a shift with start > end wraps past
; midnight (a night shift). (now-min) is minutes-since-midnight.
; ----------------------------------------------------------------------------



; (work-starts-soon ?start ?end): NOT on shift now, and the shift's next start is
; within the 120-minute lead. delta = start*60 - now-min, wrapped into [0,1440)
; so a just-before-midnight now still sees an early-morning start as soon.
(define-macro work-lead-hours () 2)


; Elapsed days since the most recent ?what. The (none ..) gate answers "never done"
; FIRST, so the recall only runs when a record exists. The record is handed to
; (elapsed ..) WHOLE rather than projected: callers pass /ever patterns, which match
; a RUNNING act as readily as a concluded one, and an ongoing record's .end is @ongoing -
; abs-seconds reads that as the epoch, so every elapsed test against it passes. time-since
; takes the start of an ongoing event and the end of a concluded one, which is the answer
; either way: nothing is more recent than what is happening now.
(define-macro days-since-last (?what)
  (if (none ?what)
    (then 36500) ; 100 years in days - never done
    (else (elapsed /days (highest /end ?what)))))

; The same count as a float, for a caller that weighs it.
(define-macro days-since-last-float (?what)
  (if (none ?what)
    (then 36500.0)
    (else (elapsed /days /float (highest /end ?what)))))


