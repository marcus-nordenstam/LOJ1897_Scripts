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
      (and (>= (now-hour) ?start) (< (now-hour) ?end))
      (or  (>= (now-hour) ?start) (< (now-hour) ?end))))

; (work-starts-soon ?start ?end): NOT on shift now, and the shift's next start is
; within the 120-minute lead. delta = start*60 - now-min, wrapped into [0,1440)
; so a just-before-midnight now still sees an early-morning start as soon.
(define-macro work-starts-soon (?start ?end)
  (and (not (in-work-hours ?start ?end))
       (> (if (< (- (* ?start 60) (now-min)) 0)
              (+ (- (* ?start 60) (now-min)) 1440)
              (- (* ?start 60) (now-min))) 0)
       (<= (if (< (- (* ?start 60) (now-min)) 0)
               (+ (- (* ?start 60) (now-min)) 1440)
               (- (* ?start 60) (now-min))) 120)))

; (minutes-until-shift-end ?end): minutes from now until the shift END hour,
; wrapped to tomorrow when end is already past (a stay duration through the shift).
(define-macro minutes-until-shift-end (?end)
  (if (<= (- (* ?end 60) (now-min)) 0)
      (+ (- (* ?end 60) (now-min)) 1440)
      (- (* ?end 60) (now-min))))
