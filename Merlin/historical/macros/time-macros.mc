; ----------------------------------------------------------------------------
; time_macros.hs - shift / clock arithmetic, pure .hs over (now-hour)/(now-minute).
;
; These fold the old C++ shift ops (in-work-hours / work-starts-soon /
; minutes-until-shift-end + the t_hse_engine helper methods) into macros. The
; only irreducible pieces are the clock sources (now-hour) / (now-minute); every
; window rule + tuning constant (the 120-minute lead, the 1440 min/day wrap) is
; authored HERE, not baked in C++.
;
; ?start / ?end are shift hours (0..23); a shift with start > end wraps past
; midnight (a night shift). (now-min) is minutes-since-midnight.
; ----------------------------------------------------------------------------

(define-macro now-min ()
  (+ (* (now-hour) 60) (now-minute)))

; (in-work-hours ?start ?end): is the clock hour inside [start, end)? A start>end
; shift wraps midnight (the disjunctive branch).
(define-macro in-work-hours (?start ?end)
  (if (<= ?start ?end)
      (then (and (>= (now-hour) ?start) (< (now-hour) ?end)))
      (else (or  (>= (now-hour) ?start) (< (now-hour) ?end)))))

; (work-starts-soon ?start ?end): NOT on shift now, and the shift's next start is
; within the 120-minute lead. delta = start*60 - now-min, wrapped into [0,1440)
; so a just-before-midnight now still sees an early-morning start as soon.
(define-macro work-starts-soon (?start ?end)
  (and (not (in-work-hours ?start ?end))
       (> (if (< (- (* ?start 60) (now-min)) 0)
              (then (+ (- (* ?start 60) (now-min)) 1440))
              (else (- (* ?start 60) (now-min)))) 0)
       (<= (if (< (- (* ?start 60) (now-min)) 0)
               (then (+ (- (* ?start 60) (now-min)) 1440))
               (else (- (* ?start 60) (now-min)))) 120)))

; Elapsed days since the most recent ?what ended. The (none ..) gate answers
; "never done" FIRST, so the (highest ..) recall only runs when a record
; exists and its .end is always a concrete date - no sentinel reads.
(define-macro days-since-last (?what)
  (if (none ?what)
    (then 36500) ; 100 years in days - never done
    (else (/ (- (now-abs-seconds) (abs-seconds (highest /end ?what).end)) 86400))))

; ----------------------------------------------------------------------------
; Age from a KNOWN birth date (belief-reading; replaces the omniscient C++
; (years-old) op that read the env birth-date attr). Composed from the general
; date primitives (date-now) + (year|month|day <date>), which decompose ANY date -
; a stored birth-date, today, an anniversary. `years-old` is EXACT: full years
; elapsed, minus one until this year's birthday falls.
; ----------------------------------------------------------------------------

; (birthday-passed ?bd): has the birthday named by date ?bd already arrived this
; year (today counts)? Month-then-day comparison against today.
(define-macro birthday-passed (?bd)
  (or (> (month (date-now)) (month ?bd))
      (and (= (month (date-now)) (month ?bd))
           (>= (day (date-now)) (day ?bd)))))

; (years-old ?who): the EXACT whole-years age, read from ?who's OWN {?who birth-date
; <date>} belief - mental, no env attr, no omniscience. Works on @self and on anyone
; whose birth-date the mind has learned (friends-and-closer); for strangers use the
; perceived age-band predicates (age_macros.hs) instead.
(define-macro years-old (?who)
  (- (- (year (date-now)) (year (any {?who birth-date}).target))
     (if (birthday-passed (any {?who birth-date}).target) (then 0) (else 1))))

; (job-tenure ?who): whole years since ?who's current job RANK began - the
; interval-start of the {<job> level <grade>} belief on the job mental object
; (level is @excl: one ongoing rank belief). Replaces the C++ (job-tenure) op with
; the same composition every date macro uses: (any ..).start + (year ...). A
; jobless / rankless ?who reads 0 ((any ..).start fails -> (year) falls back to the
; current year -> zero diff). Use with ?who = @self (reads the deliberating mind's
; own job object).
(define-macro job-tenure (?who)
  (- (year (date-now))
     (year (any {(any {?who job}).target level}).start)))

