; ----------------------------------------------------------------------------
; attend ?occ - the DOING of occasion attendance (a task, not a goal): go to the
; venue and stay through the window. Shared by host and guest alike - co-presence
; at the venue IS the attendance every other attendee (and the detective trail)
; reads. The desire that RAISES this task - an invitation held / an occasion
; organized whose held_on date has come - lives in attend_think.hs; a wedding
; principal's extra vow duty is its own task (wed-task.hs). The physical work
; routes through the shared enter / DWELL actions.
;
; ?occ is read straight off the task head; the venue + presence gate are roles
; (change-driven), and only the intra-day timing rides (when).
; ----------------------------------------------------------------------------

(npc-task {@self attend ?occ}:?a-rel
  (tar occasion)
  (and
    ; GO: I know the venue and I am not there yet -> head to it (in the window).
    (try
      (role ?venue {?occ venue ?venue})
      (role @self (not (spatial @self building ?venue)))
      (when (and {?occ hours ?start ?end}
                 (attend-in-window ?start ?end)))
      (utility (* 10 (attend-utility ?occ)))
      (effects (maintain-proposal {@self enter ?venue})))

    ; STAY: I am at the venue in the window -> dwell. The stay IS the attendance.
    (try
      (role ?venue {?occ venue ?venue})
      (role @self (spatial @self building ?venue))
      (when (and {?occ hours ?start ?end}
                 (attend-in-window ?start ?end)))
      (utility (* 10 (attend-utility ?occ)))
      (effects (maintain-proposal {@self DWELL ?venue (+ (now-hour) 1)})))))
