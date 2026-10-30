(include "../macros/occasion-macros.mc")

(define-func date-is-today (?d)
  (eq ?d (time date)))

(define-func date-before-today (?d)
  (or (< (year ?d) (year (time date)))
      (and (= (year ?d) (year (time date)))
           (or (< (month ?d) (month (time date)))
               (and (= (month ?d) (month (time date)))
                    (< (day ?d) (day (time date))))))))

(define-func date-after-today (?d)
  (not (or (date-is-today ?d) (date-before-today ?d))))

; The day an occasion planned ?months ahead is held: the first day the run lives at or after the
; occasion day of that month.
(define-func occasion-date-ahead (?months)
  (+ (time month) ?months): ?month
  (next-lived-date (cond (case (> ?month 12) (create-date (+ (time year) 1) (- ?month 12) (occasion-day)))
                         (else (create-date (time year) ?month (occasion-day))))))

; Wake at the window's opening, so an attendee busy elsewhere gets the chance to set out.
(define-func set-occasion-alarm (?start)
  (set-think-alarm (+ (time seconds)
                      (seconds (minutes-until-hour (- ?start (attend-prep-lead))) min))))

; A guest's base willingness scaled by warmth toward the host: hostile 0.6x .. warm 1.4x.
(define-func attend-guest-scaled (?occ)
  (any {?occ host ?host})
  (* (attend-guest-base)
     (+ 1.0 (* 0.2 (stance-band ?host warmth)))))

; The day the bride sets for her wedding: the day her family set while it is still to come, else
; the first lived day the wedding lead allows.
(define-func wedding-date ()
  (bind (any {@self wedding-day ?}) ?set-day)
  (cond (case (and (is-belief ?set-day) (not (date-before-today ?set-day.target))) ?set-day.target)
        (else (occasion-date-ahead (wedding-lead-months)))))

