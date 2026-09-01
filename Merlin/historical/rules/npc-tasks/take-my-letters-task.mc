; ----------------------------------------------------------------------------
; take-my-letters ?stack - sort ?stack's docs via the GENERIC stack-browse: browse surfaces
; each doc into hand marked pending; this consumer KEEPS the ones addressed to ME (my name,
; or a duty I hold) and marks the rest handled (browse re-files them at the bottom).
; Concludes when the browse round concludes. NO away rung: the round RESUMES when @self is
; back at the stack (browse gates fail from afar and the task idles running).
; ----------------------------------------------------------------------------

(npc-task {@self take-my-letters ?stack}:?take-letters-rel
  (tar @excl stack)
  (and
    (try
      (when -{@self stack-browse ?stack /caused_by ?take-letters-rel /ever})
      (utility errand)
      (effects
               (begin-proposal {@self stack-browse ?stack})))
    (try
      (role @self {@self name ?name})
      (role ?doc [k document] (spatial @self hold)
            (= (bb-read ?doc browse-status) pending))
      (effects
        (tolerate (attr ?doc addressee): ?addressee)
        (tolerate (attr ?doc addressee-duty): ?duty)
        (if (or (= ?addressee ?name)
                {@self duty-to ? ?duty})
            (then
                  (bb-write ?doc browse-status kept))
            (else
                  (bb-write ?doc browse-status handled)))))
    (try
      (when {@self stack-browse ?stack /succ /caused_by ?take-letters-rel})
      (effects
               (set-outcome ?take-letters-rel /succ)))
    (try
      (effects ))))
