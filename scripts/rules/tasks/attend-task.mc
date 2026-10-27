; ----------------------------------------------------------------------------
; attend ?occ - the DOING of occasion attendance (a task, not a goal): go to the
; venue and stay through the window. Shared by host and guest alike - co-presence
; at the venue IS the attendance every other attendee (and the detective trail)
; reads. The desire that RAISES this task - an invitation held / an occasion
; organized whose held-on date has come - lives in attend_think.mc; a wedding
; principal's extra vow duty is its own task (wed-task.mc). The physical work
; routes through go and the DWELL action, and the task concludes once the hours are over.
;
; ?occ is read straight off the task head; the venue + presence gate are roles
; (change-driven), and only the intra-day timing rides (when).
; ----------------------------------------------------------------------------

(task {@self attend ?occ}:?attend
  (tar [k occasion] @object)
  (and
    ; ALARM: think again when the window opens.
    (try
      (role ?occ {?occ hours ?start ?end}
        (effects (set-occasion-alarm ?start))))

    ; GO: I know the venue and I am not there yet -> head to it (in the window).
    (try
      (role ?occ {?occ hours ?start ?end}
        (role ?venue {?occ venue ?venue}
          (role @self (not (spatial @self building ?venue))
            (when (hours (- ?start (attend-prep-lead)) ?end))
            (effects (maintain-proposal {@self go-to ?venue}))))))

    ; STAY: I am at the venue in the window -> dwell to its end. The stay IS the attendance.
    (try
      (role ?occ {?occ hours ?start ?end}
        (role ?venue {?occ venue ?venue}
          (role @self (spatial @self building ?venue)
            (when (hours (- ?start (attend-prep-lead)) ?end))
            (effects (maintain-proposal {@self DWELL ?venue ?end}))))))

    ; OVER, having stayed: attended.
    (try
      (role ?occ {?occ hours ?start ?end}
        (role ?venue {?occ venue ?venue}
                     {@self DWELL ?venue ? /succ /caused_by ?attend /ever}
          (when (>= (time hour) ?end))
          (effects (set-outcome ?attend /succ)))))

    ; OVER, never having stayed: missed it.
    (try
      (role ?occ {?occ hours ?start ?end}
        (role ?venue {?occ venue ?venue}
                     -{@self DWELL ?venue ? /succ /caused_by ?attend /ever}
          (when (>= (time hour) ?end))
          (effects (set-outcome ?attend /fail)))))))
