; ----------------------------------------------------------------------------
; take-applications ?stack - sort ?stack's docs via the GENERIC stack-browse: browse lifts
; each doc into hand; this consumer writes its verdict on the running browse - KEEP every
; application, handled for the rest (browse re-files them at the bottom). Concludes when
; the browse round concludes. The office twin of take-my-letters.
; ----------------------------------------------------------------------------

(npc-task {@self take-applications ?stack}:?take-apps-rel
  (tar @excl stack)
  (and
    (try
      (role @self -{@self stack-browse ?stack /succ /caused_by ?take-apps-rel})
      (utility obligation)
      (effects (maintain-proposal {@self stack-browse ?stack})))
    (try
      (role @self {@self stack-browse ?stack /ever /caused_by ?take-apps-rel}:?browse
                  (bb-any ?browse inflight)
                  (bb-none ?browse verdict))
      (effects
        (bb-read ?browse inflight): ?doc
        (if (is-a ?doc [k application])
            (then (bb-write ?browse verdict kept))
            (else (bb-write ?browse verdict handled)))))
    (try
      (role @self {@self stack-browse ?stack /succ /caused_by ?take-apps-rel})
      (effects (set-outcome ?take-apps-rel /succ)))))
