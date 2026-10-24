; ----------------------------------------------------------------------------
; worship.mc - a church's hours of divine service, as its members reckon them: whether one is on
; or about to begin, and the think alarms that wake a man for the day's services.
; ----------------------------------------------------------------------------

(include "../macros/time-macros.mc")

; learn-service-hours - @self knows the hours of divine service ?church keeps.
(define-func learn-service-hours (?church)
  (for-each-row church_services [/service-hours ?lsh-hours]
    (begin-belief {?church service-hours ?lsh-hours})))

; service-starts-soon - the service ?hours is not on, and begins within the lead it takes to get
; to church.
(define-func service-starts-soon (?hours)
  (and (not (within (time seconds) ?hours))
       (<= (next-start ?hours (time seconds)) (+ (time seconds) (seconds (service-lead-hours) h)))))

; service-due - a service of ?church is on, or about to begin, as @self knows its hours.
(define-func service-due (?church)
  (bind @false ?sd-due)
  (for-each ?sd (every {?church service-hours ?})
    (bind ?sd.target ?sd-hours)
    (if (or (within (time seconds) ?sd-hours) (service-starts-soon ?sd-hours))
        (then (bind @true ?sd-due))))
  ?sd-due)

; book-service-alarms - wake @self for each service of ?church within the booking horizon: when
; it is time to set out, and the second after it ends, when attending it is no longer owed.
(define-func book-service-alarms (?church)
  (bind (+ (time seconds) (seconds (service-booking-hours) h)) ?bsa-horizon)
  (for-each ?bsa (every {?church service-hours ?})
    (bind ?bsa.target ?bsa-hours)
    (bind (- (next-start ?bsa-hours (time seconds)) (seconds (service-lead-hours) h)) ?bsa-set-out)
    (if (and (> ?bsa-set-out (time seconds)) (<= ?bsa-set-out ?bsa-horizon))
        (then (set-think-alarm ?bsa-set-out)))
    (bind (+ (next-end ?bsa-hours (time seconds)) 1) ?bsa-over)
    (if (<= ?bsa-over ?bsa-horizon)
        (then (set-think-alarm ?bsa-over)))))
