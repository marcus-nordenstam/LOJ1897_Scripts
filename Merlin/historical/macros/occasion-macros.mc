; ----------------------------------------------------------------------------
; occasion_macros.hs - shared timing / desirability / date helpers for the
; occasion lanes (the attend task, the wedding vow duty, their drivers). All
; content-free: the prep-lead / utility tiers are authored here, the window
; arithmetic is the same in-work-hours the work shifts use, the date test rides
; the generic (year)/(month) reads over the occasion's own held-on belief.
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
  (if {@self physical-mobility [k bedridden]} (then 0)
    (else (if {@self organize ?occ} (then (attend-host-utility))
      (else (if {@self goal {@self kill ?}}
          (then (max (attend-crasher-utility) (attend-guest-scaled ?occ)))
        (else (attend-guest-scaled ?occ))))))))

; The occasion's held-on date lands in the current month (hsim is monthly-resolution,
; so month + year is the natural grain for "the day has come").
(define-macro date-in-current-month (?d)
  (and (= (year ?d) (year (date-now)))
       (= (month ?d) (month (date-now)))))

; plan-occasion - the host stages one. He mints the occasion object AT the venue,
; decorates it with the constitutive beliefs the attend lane reads (host / venue /
; hours / held-on) and takes the organizing duty. Guests learn of it the only way
; anyone learns anything: an invitation letter posted to each. ?months is the lead
; time; a lead that runs past December rolls into next year.
(define-macro plan-occasion (?po-kind ?po-venue ?po-months ?po-start ?po-end)
  (if (substantial ?po-venue)
    (then
      (+ (month) ?po-months): ?po-m
      (if (> ?po-m 12)
          (then (create-date (+ (year) 1) (- ?po-m 12) 15))
          (else (create-date (year) ?po-m 15))): ?po-date
      (create-entity ?po-kind ?po-venue): ?po-occ
      (if ?po-occ
        (then
          (begin-belief {?po-occ host @self})
          (begin-belief {?po-occ venue ?po-venue})
          (begin-belief {?po-occ hours ?po-start ?po-end})
          (begin-belief {?po-occ held-on ?po-date})
          (begin-belief {@self organize ?po-occ})
          (for-each ?po-guest (every {@self friend ?})
            (bind ?po-guest.target ?po-invitee)
            (post-blank-letter [k invitation-letter]
              (any {?po-invitee home ?}).target ?po-invitee)))))))
