; ----------------------------------------------------------------------------
; take_my_letters ?stack - sort ?stack's docs via the GENERIC stack_browse: browse surfaces
; each doc into hand marked pending; this consumer KEEPS the ones addressed to ME (my name,
; or a duty I hold) and marks the rest handled (browse re-files them at the bottom).
; Concludes when the browse round concludes. NO away rung: the round RESUMES when @self is
; back at the stack (browse gates fail from afar and the task idles running).
; ----------------------------------------------------------------------------

(npc-task {@self take_my_letters ?stack}:?take-letters-rel
  (tar @excl stack)
  (and
    (try
      (when (none {@self stack_browse ?stack /caused_by ?take-letters-rel /ever}))
      (utility errand)
      (effects (debug-print "TML_BROWSE")
               (begin-proposal {@self stack_browse ?stack})))
    (try
      (role @self {@self name ?name})
      (role ?doc [k document] (spatial @self hold)
            (= (bb-read ?doc browse-status) pending))
      (effects
        (tolerate (attr ?doc addressee): ?addressee)
        (tolerate (attr ?doc addressee_duty): ?duty)
        (if (or (= ?addressee ?name)
                (believes {@self duty_to ? ?duty}))
            (then (debug-print "TML_KEEP doc=?doc")
                  (bb-write ?doc browse-status kept))
            (else (debug-print "TML_HANDLE doc=?doc")
                  (bb-write ?doc browse-status handled)))))
    (try
      (when (any {@self stack_browse ?stack /succ /caused_by ?take-letters-rel}))
      (effects (debug-print "TML_DONE")
               (set-outcome ?take-letters-rel succ)))
    (try
      (effects (debug-print "TML_P_TASK stk=?stack")))))
