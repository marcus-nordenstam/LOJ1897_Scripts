; ----------------------------------------------------------------------------
; unenrol ?reg - THE one dumb roster-strike: drop @self's row from the register ?reg
; the proposing task resolved. The twin of ENROL. Pen crosses out paper; WHICH register
; is the task's decision (resigned club, quit firm), handed in on the pattern. @self ends
; his own membership/employment belief think-side once his row is gone.
; ----------------------------------------------------------------------------

(npc-action {@self UNENROL ?reg}:?un-rel
  (duration 15)
  (effects
    (remove-doc-record [k employee_register] ?reg (find worker @self))
    (set-outcome ?un-rel succ)))
