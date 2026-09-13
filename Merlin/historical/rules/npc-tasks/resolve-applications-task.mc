; ----------------------------------------------------------------------------
; resolve-applications - the recruit officer's verdict round over the application FORMS
; still in his hand. The PAPER is the queue: he owes an answer to every form he holds,
; and an answered form is burned by the recruit-staff rung that follows the verdict into
; the post, so the round drains to empty and concludes. Reading a form made him HEAR OF
; the man who wrote it - a name, a home, and the apply-for he plainly completed, held
; about HIM and reached through {?app written-by ?man}. He is a man @self has heard of
; and never met until one walks through his door.
;
; NOTHING is pencilled against a seat here. The officer writes to a man; the letter in the
; post IS the promise, and two men may hold letters for one post. The day one comes to take
; it up, the man at the counter and this paper man fuse on the name - and whoever arrives
; first is hired, the other told who holds it.
;
; A form ALREADY ANSWERED is off the list, and ONLY that test. It must not also exclude a
; form whose draft is RUNNING: maintain-proposal holds an act only while its rung keeps
; passing, so a -{.. /pres} guard here goes false the instant draft-verdict is promoted,
; the rung stops holding, its utility source is removed, and the engine withdraws the very
; task it just started (/interrupted, k_end_proposal_withdrawn - measured: admitted and
; vanished in the same cycle, six times). A guard that fires on your own act kills it.
;
; Nor an /ever record: a draft cut off at five o'clock concluded nothing and answered
; nobody, and that form would then sit in his hand for good.
;
; ANSWERING IS THE DUTY, so both drafting rungs carry it at the duty's own band. They
; used to ride (utility fallback), which is not a low band but a PIN TO THE FLOOR of the
; auction - "only if the body has nothing else at all to do". At his post the body always
; has something else: DWELL, standing at the counter. So the letter lost every auction it
; ever entered and no verdict was ever written (measured: CREATE-ENTITY [k offer-letter]
; proposed 6 times at idle:0, beaten by DWELL every time).
;
; No relative order between them - they are mutually exclusive by construction, one on a
; standing offer for this name and the other on the absence of one.
;
; Both drafting rungs take the lock and answer ONE form at a time: two drafts at once
; propose the very same create-a-letter act, and one letter cannot answer two men.
; ----------------------------------------------------------------------------

(npc-task {@self resolve-applications}:?rt-rel
  (track-skill-level [k personnel])
  (and
    ; PENCIL THE SEAT AGAINST A MAN. An open line, and a form in hand asking for that kind
    ; of work. The object is minted here and only here; (o ..) resolves to the one already
    ; standing if @self has met him before, so a former employee re-applying does not
    ; become a second man.
    ; THE OFFER. ONE rung: an unanswered form, the man who wrote it, and an unfilled seat
    ; of the kind he asked for. It decides and it writes, because deciding to offer a man a
    ; post and writing to tell him so are one piece of business.
    ;
    ; The gate is "am I already drafting an offer to ANYBODY" - a live lookup in the action
    ; pipeline, true while the draft is proposed OR running. So one letter is written at a
    ; time and finished before the next is started, and if the draft dies any other way the
    ; gate reopens and he tries again - this man or another, whichever the world now
    ; favours. -{@self draft-verdict ?app ? /succ} is what keeps an ANSWERED form answered.
    ;
    ; BEGIN-proposal, and this is the shape it exists for: the condition to START (no draft
    ; in flight) is not the condition to STOP (the letter is in the post), and a MAINTAINED
    ; proposal would be reaped the instant its own gate went false - withdraw_proposal stops
    ; a running act, so the draft would be interrupted in the cycle it was admitted. A begun
    ; proposal obviates its rule-support and is freed by its act concluding, so no twin
    ; end-rule is needed: draft-verdict sets its own outcome.
    ;
    ; NOTHING is pencilled against the seat. A promise is a letter in the post, not a note
    ; in the officer's head; two men may both be written to, and the first through the door
    ; is hired while the second is told who holds it (recruit-staff's counter rungs).
    (try
      (lock-rule)
      (role ?org {@self duty-to ?org recruit-staff})
      (role ?applicant [k human] {?applicant apply-for ?jk ? /succ})
      (role ?app [k application] (spatial ?app held-by @self)
                                 {@self READ ?app /succ}
                                 -{@self draft-verdict ?app ? /succ}
                                 {?app written-by ?applicant})
      ; The SEAT: unfilled, and OF HIS KIND - cast on ?jk rather than tested in a gate, so
      ; the lock's one activation cannot be spent on a seat that was never a candidate.
      ; Cast LAST, after the man it is for: cast before the roles it shares no variable
      ; with, this role admits nothing at all and the rung goes silently dead (measured:
      ; 0 activations against 20 with the same filters cast last).
      (role ?job ?jk {?job org ?org}
                     {?job job-id ?}
                     -{?job filled-by ?})
      (when (not (proposed {@self draft-verdict ?app [k offer-letter]})))
      (utility obligation)
      (effects (begin-proposal {@self draft-verdict ?app [k offer-letter]})))

    ; THE REJECTION. No open post of his kind remains un-offered, so there is nothing to
    ; give him. He stays a man @self has heard of and never met, and the hearing of him
    ; fades with everything else he has no reason to keep.
    (try
      (lock-rule)
      (role ?org {@self duty-to ?org recruit-staff})
      (role ?applicant [k human] {?applicant apply-for ?jk ? /succ})
      (role ?app [k application] (spatial ?app held-by @self)
                                 {@self READ ?app /succ}
                                 -{@self draft-verdict ?app ? /succ}
                                 {?app written-by ?applicant})
      (when (unsubstantial (open-job-for ?org ?jk)))
      (utility obligation)
      (effects (maintain-proposal {@self draft-verdict ?app [k rejection-letter]})))

    (try
      (when (empty (spatial @self hold [k application])))
      (effects (set-outcome ?rt-rel /succ)))))
