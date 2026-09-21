; the point of this task is to gain the {? job ?job} belief,
; with the expectation that it will be {@self job ?job} since you are accepting
; the offer for ?job.  Once you have shown up and announced yourself,
; the recruiter will either tell you that the job is now yours,
; or that it's someone else's ({?other job ?job}), either way, you will have gained the
; correct job belief.
;
; NOT observable: the seat is a mental object, so nobody reads WHICH seat off the act.
; You TELL the officer - your name and what you are here for - and that is how the
; counter knows a man and his errand.
;
; Four rungs, exclusive by where you stand: not there / there and not yet announced /
; announced and not yet told / told. A (try ..)'s proposal is withdrawn the moment its
; roles stop admitting, which is what ends the wait when the word lands; a (stage ..)
; that minted a DWELL would advance only when the DWELL itself ended.

(npc-task {@self accept-job-offer ?job}:?accept
  (aspect labour)
  (tar [k job] @object)
  (utility obligation)
  ; The seat's org keeps its door at ?wp - where the errand goes.
  (role ?org {?job org ?org}
    (role ?wp {?org workplace ?wp}
      (stable-or
        ; if you're not at the job's workplace, then go there
        (try
          (role @self (not (spatial @self space ?wp))
            (effects (maintain-proposal {@self go ?wp}))))

        ; if you're at the workplace and in the same room as the recruiter, then announce
        ; yourself - who you are and what you are here for - so that the recruiter knows.
        (try
          (role ?officer [k human] {?officer recruit-staff ?}
                                   (spatial ?officer co-located @self)
            (role @self {@self name ?myname}
                        -{@self SAY ? ?officer /succ /caused_by ?accept}
              ; The seat travels as its DESCRIPTION - kind, org and line - the way the officer's own
              ; word names it: a seat has no name for the wire to carry.
              (effects
                (any {?job job-id ?}).target: ?line
                (kind ?job): ?jk
                (utterable-msg {@i name ?myname}
                               {@i accept-job-offer (o ?jk {@o org ?org} {@o job-id ?line})}): ?msg
                (check ?msg)
                (maintain-proposal {@self SAY ?msg ?officer})))))

        ; wait until the officer responds with who got the job
        (try
          (role ?officer [k human] {?officer recruit-staff ?}
                                   (spatial ?officer co-located @self)
                                   -{?officer SAY (utterable-msg {? job ?}) @self /succ}
            (role @self {@self SAY ? ?officer /succ /caused_by ?accept}
              (effects (maintain-proposal {@self DWELL ?wp (+ (now-hour) 1)})))))

        ; told: this task is successful now, whether or not the job turns out to be mine.
        ; TAKEN ON. Her word put {@self job ?job} in his mind, and the seat came decorated off
        ; the offer letter - level, salary, shift hours. What is his alone to know: since when,
        ; and that the premises are now his to be in.
        (try
          (role ?officer [k human] {?officer recruit-staff ?}
                                   {?officer SAY (utterable-msg {? job ?}) @self /succ}
            (role @self {@self SAY ? ?officer /succ /caused_by ?accept}
                        {@self job ?job}
              (effects
                (if -{?job since ?} (then (begin-belief {?job since (year)})))
                (if -{?wp occupant @self} (then (begin-belief {?wp occupant @self})))
                (expect (any {?job level ?}) "labour: taken on, but the seat carries no level")
                (expect (any {?job salary ?}) "labour: taken on, but the seat carries no salary")
                (set-outcome ?accept /succ)))))
        ; TURNED AWAY. Her word named the man who holds the seat he came for, and she only
        ; says so when no seat of his kind is open. The telling must be THIS errand's - a holder
        ; learned on an earlier visit is not a refusal. The offer is spent.
        (try
          (role ?officer [k human] {?officer recruit-staff ?}
            (role @self {@self SAY ? ?officer /succ /caused_by ?accept}
              (role ?holder [k human] {?holder job ?job}:?held
                (when (and (!= ?holder @self)
                           (>= (abs-seconds ?held.start) (abs-seconds ?accept.start))))
                (effects
                  (for-each ?orel (every {?job offered-to @self})
                    (end-belief ?orel))
                  (set-outcome ?accept /fail))))))))))
