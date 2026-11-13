(define-func work-starts-soon (?hours)
  (and (not (within (time seconds) ?hours))
       (<= (next-start ?hours (time seconds)) (+ (time seconds) (seconds (work-lead-hours) h)))))

; The state a home keeps each meal's hour under.
(define-table meal_hours (fields meal hour-label)
  (record [k breakfast] breakfast-hour)
  (record [k lunch]     lunch-hour)
  (record [k luncheon]  lunch-hour)
  (record [k supper]    supper-hour))

; (when ?what ?where) - when ?what happens, as @self knows it: a meal's hour at ?where (@self's own
; home when ?where is @nothing), else the day an occasion is held on; @unknown when @self does not know.
(define-func when (?what ?where)
  (bind @unknown ?time)
  (bind @false ?meal)
  (bind (flip (eq ?where @nothing) (any {@self home ?}).target ?where) ?place)
  (for-each-row meal_hours [/meal ?kept] [/hour-label ?label]
    (if (= ?what ?kept)
        (then (bind @true ?meal)
              (any {?place ?label ?hour=@unknown})
              (bind ?hour ?time)
              (break))))
  (if (not ?meal)
      (then (any {?what held-on ?day=@unknown})
            (bind ?day ?time)))
  ?time)
