; ----------------------------------------------------------------------------
; SACK ?worker ?reg - the boss lets the worker go and strikes his line off the org's
; employee register ?reg, which the proposer (tasks/dismiss-task.mc) chose.
; ----------------------------------------------------------------------------

(action {@self SACK ?worker ?reg}:?SACK
  (motor mouth)
  (duration (seconds 45 min))
  (effects
    (table-set ?reg (where worker (name ?worker))
                    worker @nothing level @nothing hiring-date @nothing)
    ; the grudge: the dismissed man resents the boss who let him go (a named motive)
    ; TELEPATHY - a rule cannot move ANOTHER mind's stance. Restore this as the other
    ; party's own reflex on the act. Commented out pending that redesign.
    ; (nudge-stance ?worker @self warmth -0.5)
    (set-outcome ?SACK /succ)))
