; The occasion's held-on date lands in the current month (hsim is monthly-resolution,
; so month + year is the natural grain for "the day has come").
(define-func date-in-current-month (?d)
  (and (= (year ?d) (year (time date)))
       (= (month ?d) (month (time date)))))

; Wake at the window's opening, so an attendee busy elsewhere gets the chance to set out.
(define-func set-occasion-alarm (?start)
  (set-think-alarm (+ (time seconds)
                      (seconds (minutes-until-hour (- ?start (attend-prep-lead))) min))))

; A guest's base willingness scaled by warmth toward the host: hostile 0.6x .. warm 1.4x.
(define-func attend-guest-scaled (?occ)
  (any {?occ host ?host})
  (* (attend-guest-base)
     (+ 1.0 (* 0.2 (stance-band ?host warmth)))))
