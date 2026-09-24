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

(npc-task {@self attend ?occ}:?a-rel
  (tar [k occasion] @object)
  (and
    ; GO: I know the venue and I am not there yet -> head to it (in the window).
    (try
      (role ?venue {?occ venue ?venue}
        (role @self (not (spatial @self building ?venue))
          (when (and {?occ hours ?start ?end}
                     (attend-in-window ?start ?end)))
          (effects (maintain-proposal {@self go ?venue})))))

    ; STAY: I am at the venue in the window -> dwell to its end. The stay IS the attendance.
    (try
      (role ?venue {?occ venue ?venue}
        (role @self (spatial @self building ?venue)
          (when (and {?occ hours ?start ?end}
                     (attend-in-window ?start ?end)))
          (effects (maintain-proposal {@self DWELL ?venue ?end})))))

    ; OVER, having stayed: attended.
    (try
      (role ?venue {?occ venue ?venue}
        (when (and {?occ hours ?start ?end}
                   (>= (now-hour) ?end)
                   {@self DWELL ?venue ? /succ /caused_by ?a-rel /ever}))
        (effects (set-outcome ?a-rel /succ))))

    ; OVER, never having stayed: missed it.
    (try
      (role ?venue {?occ venue ?venue}
        (when (and {?occ hours ?start ?end}
                   (>= (now-hour) ?end)
                   -{@self DWELL ?venue ? /succ /caused_by ?a-rel /ever}))
        (effects (set-outcome ?a-rel /fail))))))
