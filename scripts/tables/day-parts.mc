; The parts of the day. START is the hour a part begins at in the partition of the day - which
; part an instant falls in: the part a habit is kept in, (time band). FROM and TO are the hours a
; question naming the part covers, ending before TO; an hour past 24 is the small hours of the
; next day. A window is wider than its part, since nobody asked about "last night" leaves out the
; evening: evening and night both cover five in the afternoon to five in the morning.
(define-table day_parts (fields part start from to)
  (record [k dawn]       4  4  8)
  (record [k morning]    7  5 12)
  (record [k midday]    11 11 14)
  (record [k afternoon] 14 12 18)
  (record [k evening]   17 17 29)
  (record [k night]     22 17 29))
