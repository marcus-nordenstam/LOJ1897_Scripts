; ----------------------------------------------------------------------------
; QUIT-WORK ?reg - he gives notice at his workplace, and his line on the firm's employee-register
; ?reg is struck; a man who does not know the register (_) only gives the notice. The job itself
; ends in his mind, where retire decides it (tasks/retire-task.mc).
; ----------------------------------------------------------------------------

(action {@self QUIT-WORK ?reg}:?QUIT-WORK
  (motor mouth)
  (tar ?)
  (duration (seconds 60 min))
  (effects
    (if (substantial ?reg)
        (then (table-set ?reg (where worker (name @self))
                              worker @nothing level @nothing hiring-date @nothing)))
    (set-outcome ?QUIT-WORK /succ)))
