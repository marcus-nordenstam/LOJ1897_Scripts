; ----------------------------------------------------------------------------
; occasion_macros.hs - shared timing / desirability / date helpers for the
; occasion lanes (the attend task, the wedding vow duty, their drivers). All
; content-free: the prep-lead / utility tiers are authored here, the window
; arithmetic is the same in-work-hours the work shifts use, the date test rides
; the generic (year)/(month) reads over the occasion's own held_on belief.
; ----------------------------------------------------------------------------

(define-macro attend-prep-lead      () 3)       ; hours before start an attendee sets out
(define-macro attend-host-utility   () 10000)   ; a principal always attends his own occasion
(define-macro attend-crasher-utility () 5000)   ; a kill-driven crasher: above work, below host
(define-macro attend-guest-base     () 85)      ; beats the work lane (80) for the willing guest

; In the occasion's window once the prep-lead has opened (start - lead .. end).
(define-macro attend-in-window (?start ?end)
  (in-work-hours (- ?start (attend-prep-lead)) ?end))

; A guest's base willingness scaled by warmth toward the host: hostile 0.6x .. warm 1.4x.
(define-macro attend-guest-scaled (?occ)
  (* (attend-guest-base)
     (+ 1.0 (* 0.2 (stance-band (any {?occ host ?}).target warmth)))))

; Attendance desirability: 0 bedridden, MAX for the host, a floor for a kill-driven
; crasher, else the warmth-scaled guest base. Shared by the attend task's rungs.
(define-macro attend-utility (?occ)
  (if (any {@self physical_mobility [k bedridden]}) (then 0)
    (else (if (any {@self organize ?occ}) (then (attend-host-utility))
      (else (if (any {@self goal {@self kill ?}})
          (then (max (attend-crasher-utility) (attend-guest-scaled ?occ)))
        (else (attend-guest-scaled ?occ))))))))

; The occasion's held_on date lands in the current month (hsim is monthly-resolution,
; so month + year is the natural grain for "the day has come").
(define-macro date-in-current-month (?d)
  (and (= (year ?d) (year (date-now)))
       (= (month ?d) (month (date-now)))))
