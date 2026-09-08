; ----------------------------------------------------------------------------
; take-my-letters ?stack - sort ?stack's docs via the GENERIC stack-browse: browse lifts
; each doc into hand; this consumer writes its verdict on the running browse - KEEP the
; ones addressed to ME (my name, or a duty I hold) and not yet read, handled for the rest
; (browse re-files them at the bottom). Concludes when the browse round concludes. NO away
; rung: the round RESUMES when @self is back at the stack (browse gates fail from afar and
; the task idles running).
; ----------------------------------------------------------------------------

(npc-task {@self take-my-letters ?stack}:?take-letters-rel
  (tar @excl stack)
  (and
    (try
      (role @self -{@self stack-browse ?stack /succ /caused_by ?take-letters-rel})
      (utility errand)
      (effects
               (maintain-proposal {@self stack-browse ?stack})))
    (try
      (role @self {@self name ?name}
                  {@self stack-browse ?stack /ever /caused_by ?take-letters-rel}:?browse
                  (bb-any ?browse inflight)
                  (bb-none ?browse verdict))
      (effects
        (bb-read ?browse inflight): ?doc
        (tolerate (attr ?doc addressee): ?addressee)
        (tolerate (attr ?doc addressee-duty): ?duty)
        (if (and (or (= ?addressee ?name)
                     (nothing ?addressee)
                     {@self duty-to ? ?duty})
                 -{@self READ ?doc /succ})
            (then (bb-write ?browse verdict kept))
            (else (bb-write ?browse verdict handled)))))
    (try
      (role @self {@self stack-browse ?stack /succ /caused_by ?take-letters-rel})
      (effects
               (set-outcome ?take-letters-rel /succ)))))
