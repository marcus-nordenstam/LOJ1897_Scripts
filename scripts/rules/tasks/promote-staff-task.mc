; ----------------------------------------------------------------------------
; promote-staff ?worker - the DOING of a boss advancing a subordinate: go to the
; workplace and TELL him his new job level (the boss tells it, the worker hears and
; adopts it - no cross-mind write). The next rung is read off the worker's current rank
; the boss knows from reading the roster (read-roster); the level_rank ladder steps it.
; The decision (employment_think promotion) proposes this task and owns its life.
; ----------------------------------------------------------------------------

(task {@self promote-staff ?worker}:?promote-staff
  (track-skill-level [k personnel])
  (tar [k human] @object)
  (and
    ; GO: not at the workplace -> travel to it.
    (try
      (role ?job {@self job ?job}
        (role ?org {?job org ?org} {?org workplace ?wp}
          (when (not (spatial @self building ?wp)))
          (effects (maintain-proposal {@self enter ?wp})))))

    ; TELL: at the workplace -> tell him his next rung; he hears and adopts {?worker job.level ?next}.
    (try
      (role ?job {@self job ?job}
        (role ?org {?job org ?org} {?org workplace ?wp}
          (when (spatial @self building ?wp))
          (effects
            (any {?worker job.level ?cur})
            (table-match level_rank level ?cur rank ?rank)
            (table-match level_rank rank (+ ?rank 1) level ?next)
            (maintain-proposal {@self tell (utterable-msg [] {?worker job.level ?next}) ?worker})))))))
