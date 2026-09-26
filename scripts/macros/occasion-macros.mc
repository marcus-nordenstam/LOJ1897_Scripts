; ----------------------------------------------------------------------------
; occasion_macros.mc - shared timing / desirability / date helpers for the
; occasion aspect (the attend task, the wedding vow duty, their drivers). All
; content-free: the prep-lead and the guest's desirability are authored here, the window
; arithmetic is the same in-work-hours the work shifts use, the date test rides
; the generic (time year)/(time month) reads over the occasion's own held-on belief.
; ----------------------------------------------------------------------------

(define-macro attend-prep-lead      () 3)       ; hours before start an attendee sets out
(define-macro attend-crasher-value  () 500.0)    ; a kill-driven crasher's floor within the guest tier
(define-macro attend-guest-base     () 850.0)    ; the willing guest's value within the guest tier

; In the occasion's window once the prep-lead has opened (start - lead .. end).
(define-macro attend-in-window (?start ?end)
  (in-work-hours (- ?start (attend-prep-lead)) ?end))

; Wake at the window's opening, so an attendee busy elsewhere gets the chance to set out.
(define-macro set-occasion-alarm (?start)
  (set-think-alarm (+ (time seconds)
                      (seconds (minutes-until-hour (- ?start (attend-prep-lead))) min))))

; A guest's base willingness scaled by warmth toward the host: hostile 0.6x .. warm 1.4x.
(define-macro attend-guest-scaled (?occ)
  (* (attend-guest-base)
     (+ 1.0 (* 0.2 (stance-band (any {?occ host ?}).target warmth)))))

; The occasion's held-on date lands in the current month (hsim is monthly-resolution,
; so month + year is the natural grain for "the day has come").
(define-macro date-in-current-month (?d)
  (and (= (year ?d) (year (time date)))
       (= (month ?d) (month (time date)))))

