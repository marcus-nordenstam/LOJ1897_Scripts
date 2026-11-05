; ----------------------------------------------------------------------------
; The life seeds: the STATES a startup gives its founders so that what follows is lived through the
; corpus's own acts - never a marriage or a parentage minted as done. Each enters the minds it
; seeds and never proposes.
; ----------------------------------------------------------------------------

(include "../macros/occasion-macros.mc")

; seed-founding-match ?groom ?bride ?day - the two are pledged to wed on ?day: each owes the other
; the wedding, and knows the other's name and that they share his home.
(define-func seed-founding-match (?groom ?bride ?day)
  (seed-match-half ?groom ?bride ?day)
  (seed-match-half ?bride ?groom ?day))

(define-func seed-match-half (?self ?other ?day)
  (seed-housemate-half ?self ?other)
  (enter-mind ?self)
  (observe ?other): ?smh-other
  (begin-belief {@self obligation {@self wed ?smh-other} ?smh-other})
  (begin-belief {@self wedding-day ?day})
  (exit-mind))

; seed-housemate-half ?self ?other - ?self knows ?other's name and, when he has a home, that they
; share it.
(define-func seed-housemate-half (?self ?other)
  (enter-mind ?self)
  (observe ?other): ?shh-other
  (begin-belief {?shh-other name (attr ?other name)})
  (bind (any {@self home ?}) ?shh-home)
  (if (is-belief ?shh-home)
      (then (begin-belief {?shh-other home ?shh-home.target})))
  (exit-mind))

; seed-founding-matches ?first-day ?days - in every unit the first man and the first woman under
; its roof are pledged to wed in the first window the run lives, ?first-day days into it, the
; weddings spread a day apart over ?days days.
(define-func seed-founding-matches (?first-day ?days)
  (next-lived-date (time date)): ?sfm-first
  (bind 0 ?sfm-n)
  (for-each ?unit (env-entities [k unit])
    (bind @nothing ?sfm-groom)
    (bind @nothing ?sfm-bride)
    (for-each ?h (env-entities [k human])
      (if (spatial ?h unit ?unit /env)
          (then
            (if (and (unsubstantial ?sfm-groom) (= (attr ?h gender) [k male]))
                (then (bind ?h ?sfm-groom)))
            (if (and (unsubstantial ?sfm-bride) (= (attr ?h gender) [k female]))
                (then (bind ?h ?sfm-bride))))))
    (if (and (substantial ?sfm-groom) (substantial ?sfm-bride))
        (then
          (seed-founding-match ?sfm-groom ?sfm-bride (founding-wedding-day ?sfm-first ?first-day ?days ?sfm-n))
          (bind (+ ?sfm-n 1) ?sfm-n)))))

(define-func founding-wedding-day (?first ?first-day ?days ?n)
  (create-date (year ?first) (month ?first) (+ (day ?first) ?first-day (modulo ?n ?days))))
