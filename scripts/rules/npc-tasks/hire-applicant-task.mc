; ----------------------------------------------------------------------------
; hire-applicant ?applicant ?job - a man is standing at the counter to take up ?job, the
; seat he was offered: he told the officer his name and his errand. If he is one of the
; men she has heard of only on paper, the two accounts are fused first, so the promise she
; wrote lands on the man in front of her. Then the seat decides:
;   vacant -> HIRE him onto its line; the signing done, tell him it is his and conclude
;   held   -> tell him who holds it and conclude
; The seat carries everything the word needs: its kind, its org and its line.
;
; The signing, the saying and the CONCLUSION are three RUNGS, never a sequence: a sequence
; head that reads "nobody holds this seat" fells its own activation the moment the signing
; fills it, and the saying stage never runs (measured: HIRE /succ, the word interrupted).
; The conclusion is its own rung because a PROPOSED word is not a spoken one: this errand
; exists to make the man hold the seat as his, and until his answer has actually landed -
; the SAY concluded /succ - it is not done. Concluding beside the proposal would leave the
; officer certain she had answered a man who never heard her, and his own errand waits on
; that word (measured: her SAYs are interrupted like any other act).
; ----------------------------------------------------------------------------

(npc-task {@self hire-applicant ?applicant ?job}:?ha-rel
  (aspect labour)
  (track-skill-level [k personnel])
  (tar human)
  (aux [k job])
  (role ?org {@self duty-to ?org recruit-staff}
    (and
      ; THE PAPER MAN AND THE MAN: the officer heard of him off a form - a name, realis and
      ; ungrounded. The man at the counter carries the same name; fuse them, so what was
      ; promised to the one on paper is now known of the one in the room.
      (try
        (role @self {?applicant name ?pname}
          (role ?paper [k human] {?paper name ?pname}
                                 (is-reconcilable ?paper)
                                 (!= ?paper ?applicant)
            (effects (reconcile ?paper ?applicant)))))

      ; SIGN HIM ON: his seat is nobody's yet. HIRE writes a man standing in front of the
      ; book, so his reach is this rung's to assert.
      (try
        (role @self (spatial ?applicant co-located @self)
                    -{?applicant job ?}  ; he holds no seat I know of
                    -{? job ?job}        ; and nobody holds the one he came for
                    -{@self HIRE ?applicant ? /succ /caused_by ?ha-rel}
          (utility obligation always-pick)
          (effects
            (any {?job job-id ?}).target: ?line
            (maintain-proposal {@self HIRE ?applicant ?line}))))

      ; SIGNED: the book says he is on it, so the seat is his - and the word goes to him. The
      ; seat is his from the moment the line is written, which is why the officer's own two
      ; facts about it land HERE and not on the conclusion: she read her own book. The seat is
      ; named by DESCRIPTION - a job has no name; the org and the line make it THAT seat -
      ; and the message QUOTES, so the (o ..) resolves in HIS mind.
      (try
        (role @self {@self HIRE ?applicant ? /succ /caused_by ?ha-rel}
                    -{@self SAY ? ?applicant /succ /caused_by ?ha-rel}
          (utility obligation always-pick)
          (effects
            (any {?job job-id ?}).target: ?line
            (kind ?job): ?jk
            (utterable-msg {@you job (o ?jk {@o org ?org} {@o job-id ?line})}): ?msg
            (check ?msg)
            (maintain-proposal {@self SAY ?msg ?applicant})
            (if -{?applicant job ?job} (then (begin-belief {?applicant job ?job})))
            (for-each ?orel (every {?job offered-to ?}) (end-belief ?orel)))))

      ; TOLD: the word landed. Both of them hold the seat as his now, which is the whole
      ; point of the errand, so it ends.
      (try
        (role @self {@self HIRE ?applicant ? /succ /caused_by ?ha-rel}
                    {@self SAY ? ?applicant /succ /caused_by ?ha-rel}
          (utility obligation always-pick)
          (effects (set-outcome ?ha-rel /succ))))

      ; TURN HIM AWAY: his seat is held, and not by him - he is told who holds it, and that
      ; is the refusal. Spoken TO the man it is meant for: a bystander hears it as news of
      ; the seat, never as his own verdict.
      (try
        (role @self (spatial ?applicant co-located @self)
                    {? job ?job}          ; somebody holds the seat he came for
                    -{?applicant job ?}   ; and it is not him
                    -{@self HIRE ?applicant ? /succ /caused_by ?ha-rel}
                    -{@self SAY ? ?applicant /succ /caused_by ?ha-rel}
          (utility obligation always-pick)
          (effects
            (any {?job job-id ?}).target: ?line
            (kind ?job): ?jk
            (any {? job ?job}): ?held
            (bind ?held.subject ?holder)
            (utterable-msg {?holder job (o ?jk {@o org ?org} {@o job-id ?line})}): ?msg
            (check ?msg)
            (maintain-proposal {@self SAY ?msg ?applicant}))))

      ; TURNED AWAY: the refusal landed, and he knows whose the seat is.
      (try
        (role @self {? job ?job}
                    -{?applicant job ?}
                    -{@self HIRE ?applicant ? /succ /caused_by ?ha-rel}
                    {@self SAY ? ?applicant /succ /caused_by ?ha-rel}
          (utility obligation always-pick)
          (effects (set-outcome ?ha-rel /fail)))))))
