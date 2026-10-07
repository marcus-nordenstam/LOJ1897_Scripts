; The hours each part of the day spans, for the habits a mind draws from where it sees people
; go (the (habit-bands day_parts) of the building spatial label). A band starts at its first
; hour and ends before its last; night runs past midnight.
(define-table day_parts (fields band from to)
  (record [k morning]    5 12)
  (record [k afternoon] 12 17)
  (record [k evening]   17 22)
  (record [k night]     22  5))
