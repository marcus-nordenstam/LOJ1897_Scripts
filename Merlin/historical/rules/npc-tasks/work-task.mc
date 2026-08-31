; ----------------------------------------------------------------------------
; work ?wp - the day's WORK task (a bodyless umbrella, never an action), spawned by
; day_work (work_attendance_think.hs) at shift start. Its tries fan the shift into the held
; duties' tasks and the between-duties post-stay; shift_over concludes it. The ?job role is
; CONSTRAINED to the job whose org's workplace IS ?wp (an actor holds plural jobs by design).
;
;   spawn_recruit_staff : while the org's wage book is short of its authored headcount, begin
;                         the held recruit_staff duty performance (one drive at a time).
;   at_post_morning/afternoon : BE at the post - the pre/post-lunch dwell blocks, each aimed
;                         at its absolute boundary; the lowest job utility (any duty outbids).
;   shift_over : outside the working + starts-soon window -> the day's work concluded.
; ----------------------------------------------------------------------------

(npc-task {@self work ?wp}:?w-rel
  (tar structure|org|space)
  (and
    (try
      (lock-rule)
      (rng-stream employment)
      (role ?org {@self duty-to ?org recruit_staff}
                 -{?org isa [k org household]}
                 {?org record ?})
      (when (and {?org isa ?ok}
                 {?org employee-register ?reg}
                 (< (table-count ?reg)
                    (if (table-match public_orgs kind ?ok employee-count ?ec) (then ?ec) (else 2)))))
      (utility duty)
      (effects (debug-print "RC_ROOT")
               (begin-proposal {@self recruit_staff ?org})))
    (try
      (role ?job {@self job ?job})
      (role ?org {?job org ?org}
                 {?org workplace ?wp})
      (when (table-match weekday_hours_label weekday (now-weekday) label ?tl)
            (latch-eval (any {?job ?tl ?}): ?sh-rel (bind ?sh-rel.target ?start) (bind ?sh-rel.auxiliary ?end))
            (and (check ?org) (spatial @self building ?wp) (< (now-hour) 12)))
      (effects (maintain-proposal {@self DWELL ?wp (min 12 ?end)})))
    (try
      (role ?job {@self job ?job})
      (role ?org {?job org ?org}
                 {?org workplace ?wp})
      (when (table-match weekday_hours_label weekday (now-weekday) label ?tl)
            (latch-eval (any {?job ?tl ?}): ?sh-rel (bind ?sh-rel.target ?start) (bind ?sh-rel.auxiliary ?end))
            (and (check ?org) (spatial @self building ?wp) (>= (now-hour) 12)))
      (effects (maintain-proposal {@self DWELL ?wp ?end})))
    (try
      (role ?job {@self job ?job})
      (role ?org {?job org ?org}
                 {?org workplace ?wp})
      (when (table-match weekday_hours_label weekday (now-weekday) label ?tl)
            (latch-eval (any {?job ?tl ?}): ?sh-rel (bind ?sh-rel.target ?start) (bind ?sh-rel.auxiliary ?end))
            (not (or (in-work-hours ?start ?end) (work-starts-soon ?start ?end))))
      (effects (set-outcome ?w-rel /succ)))))
