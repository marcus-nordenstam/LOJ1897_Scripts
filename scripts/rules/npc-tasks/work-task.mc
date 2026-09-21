; ----------------------------------------------------------------------------
; work ?wp - the day's WORK task (a bodyless umbrella, never an action), spawned by
; day_work (work_attendance_think.mc) at shift start. Its tries fan the shift into the held
; duties' tasks and the between-duties post-stay.
;
; THE CONDITION THE TASK RUNS UNDER is its own and not any proposer's: while the shift is on
; or about to be. The job, its org and the shift window sit on the SPINE, where every rung
; reads them - the ?job role is CONSTRAINED to the job whose org's workplace IS ?wp (an actor
; holds plural jobs by design). The moment the window stops holding the task stops firing,
; and the (cease ..) is where it says what that meant: the day's work concluded.
;
;   spawn_recruit_staff : while the wage book shows an open staff line, or a notice of the
;                         org's still stands, begin the held recruit-staff duty performance
;                         (one drive at a time). The round concludes every day, so this
;                         re-spawns it each workday for as long as either is true.
;   at_post_morning/afternoon : BE at the post - the pre/post-lunch dwell blocks, each aimed
;                         at its absolute boundary; the lowest job utility (any duty outbids).
; ----------------------------------------------------------------------------

(npc-task {@self work ?wp}:?w-rel
  (tar [k structure|org|space] @object)
  (role ?job {@self job ?job}
    (role ?org {?job org ?org}
               {?org workplace ?wp}
      (when (table-match weekday_hours_label weekday (now-weekday) label ?tl)
            (latch-eval (any {?job ?tl ?}): ?sh-rel (bind ?sh-rel.target ?start) (bind ?sh-rel.auxiliary ?end))
            (on-shift ?start ?end))
      (cease (if (not (on-shift ?start ?end))
                 (then (set-outcome ?w-rel /succ))))
      (and
        (try
          (lock)
          (rng-stream employment)
          (role ?duty-org {@self duty-to ?duty-org recruit-staff}
                     -{?duty-org isa [k org household]}
                     {?duty-org record ?}
            ; The BOOK is the headcount - an empty worker cell is an open post - so nothing here
            ; consults a config table the officer has no way of knowing. The standing-notice leg
            ; is what brings him back to take a filled post's advert down.
            (role ?reg {?duty-org employee-register ?reg}
              ; A MAN AT THE COUNTER keeps the book open too: the duty that ended the minute the
              ; last seat filled left the applicants still standing there unanswered, and a man
              ; holding an offer with nobody keeping the book comes back every day (measured).
              (when (or (table-match (attr ?reg writing) worker @nothing)
                             {?duty-org display-ad ?}
                             (> (count (every {? accept-job-offer ?})) 0)))
              (utility duty)
              (effects
                       (maintain-proposal {@self recruit-staff ?duty-org})))))
        (try
          (when (and (check ?org) (at-workplace ?wp) (< (now-hour) 12)))
          (effects (maintain-proposal {@self DWELL ?wp (min 12 ?end)})))
        (try
          (when (and (check ?org) (at-workplace ?wp) (>= (now-hour) 12)))
          (effects (maintain-proposal {@self DWELL ?wp ?end})))))))
