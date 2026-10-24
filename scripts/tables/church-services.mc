; ----------------------------------------------------------------------------
; church_services.mc - the hours of divine service every church keeps. A member knows them
; (funcs/worship.mc learn-service-hours): one {<church> service-hours <weekly interval>} per row.
;
;   service       - the service's name.
;   service-hours - a weekly interval, from its first clock until its second, as long as a
;                   WORSHIP takes; inside the priest's working hours (occupation_shifts.mc).
; ----------------------------------------------------------------------------

(define-table church_services
  (fields service service-hours)
  (record early-communion (weekly [sunday] #8:00 #9:30))
  (record morning-service (weekly [sunday] #11:00 #12:30))
  (record midweek-service (weekly [wednesday] #10:30 #12:00)))
