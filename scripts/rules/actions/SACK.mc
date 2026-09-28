; ----------------------------------------------------------------------------
; sack_errand (action) - the ACT half of the employer-side job-loss split. The
; go/dwell think half lives in thinks/sack_errand.mc; this file holds the
; dwell completion that fires the worker and seeds his grudge toward the boss.
; ----------------------------------------------------------------------------

(action {@self SACK ?worker}
  (motor body legs)
  (duration (seconds 45 min))
  (effects
    (for-each ?job (every {@self job ?})
        (bind ?job.target ?sr-job)
        (for-each ?org (every {?sr-job org ?})
            (bind ?org.target ?sr-org)
            (for-each ?employee-register (every {?sr-org employee-register ?})
                (bind ?employee-register.target ?sr-reg)
                (table-set ?sr-reg (where worker (name ?worker))
                                worker @nothing level @nothing hiring-date @nothing))))
    ; the grudge: the dismissed man resents the boss who let him go (a named motive)
    ; TELEPATHY - a rule cannot move ANOTHER mind's stance. Restore this as the other
    ; party's own reflex on the act. Commented out pending that redesign.
    ; (nudge-stance ?worker @self warmth -0.5)
    (set-outcome {@self SACK} /succ)))
