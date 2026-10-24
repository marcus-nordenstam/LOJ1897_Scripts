(define-func work-starts-soon (?hours)
  (and (not (within (time seconds) ?hours))
       (<= (next-start ?hours (time seconds)) (+ (time seconds) (seconds (work-lead-hours) h)))))
