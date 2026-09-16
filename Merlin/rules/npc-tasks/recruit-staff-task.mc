; ----------------------------------------------------------------------------
; recruit-staff ?org - the PERFORMANCE of the held recruit-staff duty ({@self duty-to ?org
; recruit-staff} is the obligation; the running task is doing it). Spawned by the running
; work task while the wage book shows an open line or a notice of the org's still stands,
; and concluded EVERY DAY - a duty that can only end when the book is full never ends, and
; a task that never ends keeps its actor busy and eats every same-band bid behind it.
;
; An ORCHESTRATOR: every rung scans for one condition and proposes ONE sub-task; nothing
; is implemented here. The officer's business, per post on his own book:
;   read the book       -> read-doc ?reg            (once per round; the page is the authority)
;   open, no notice     -> post-ad ?org ?job
;   filled, notice up   -> remove-ad ?org ?job
;   a notice stands     -> collect-applications ?wp (the office post, once a day)
;   a form unread       -> read-doc ?app            (reading it is hearing of the man)
;   a man, a seat       -> draft-verdict ?p [k offer-letter]
;   a man, no seat      -> draft-verdict ?p [k rejection-letter]
;   a man at the counter-> hire-applicant ?man ?job (first through the door)
;   shift over          -> /succ
; Every rung reads what he now KNOWS - the beliefs the book and the forms put there -
; never what this task instance has done, which cannot span a shift.
; ----------------------------------------------------------------------------

(npc-task {@self recruit-staff ?org}:?rec-rel
  (aspect labour)
  ; OBSERVABLE, and for the WHOLE SHIFT: a man keeping the hiring book does it in the open,
  ; so anyone in the room reads the duty off him - that is how an applicant identifies the
  ; officer, the way you identify the bartender by the bartending.
  (obs)
  (track-skill-level [k personnel])
  (tar org)
  (lint-waive unused-role)
  (and
    ; THE BOOK, read once a round: hires and departures rewrite the page, and this read
    ; is the only thing that moves the officer's picture with it.
    (try
      (role ?reg {?org employee-register ?reg})
      (when (>= (days-since-last {@self read-doc ?reg /succ}) 1))
      (utility obligation)
      (effects (maintain-proposal {@self read-doc ?reg})))

    ; POST A NOTICE for an open post that has none. ONE posting at a time: two concurrent
    ; postings on one body share one CREATE-ENTITY and mark two posts advertised on one
    ; sheet (measured).
    (try
      (lock-rule)
      (role ?job {?job org ?org}
                 {?job job-id ?}
                 -{? job ?job}
                 -{?org display-ad ?job})
      (utility obligation)
      (effects (maintain-proposal {@self post-ad ?org ?job})))

    ; TAKE THE NOTICE DOWN for a post that has since been filled.
    (try
      (role ?job {?job org ?org}
                 {?job job-id ?}
                 {? job ?job}
                 {?org display-ad ?job})
      (utility obligation)
      (effects (maintain-proposal {@self remove-ad ?org ?job})))

    ; THE OFFICE POST, once a day while a notice stands: an application only exists in
    ; answer to one. collect-applications walks to the stack itself.
    (try
      (lock-rule)
      (role ?wp {?org workplace ?wp}
                {?org display-ad ?})
      (when (>= (days-since-last {@self collect-applications ?wp /succ}) 1))
      (utility obligation)
      (effects (maintain-proposal {@self collect-applications ?wp})))

    ; READ each form in hand, ONE AT A TIME. Reading is how the man on it comes to be
    ; known. The lock matters: this proposes a TASK per form, and every activation's
    ; proposal sits in the pipeline's task table at once - a stack of forms overflowed it
    ; (measured: t_task_util cap 16, August). A man reads one paper at a time anyway.
    (try
      (lock-rule)
      (role ?app [k application] (spatial ?app held-by @self)
                                 -{@self READ ?app /succ})
      (utility obligation)
      (effects (maintain-proposal {@self read-doc ?app})))

    ; A READ form is BURNED: its facts are beliefs now, and the paper's only other use was
    ; as a queue - the man's apply-for is that queue, and his verdict record the answer.
    (try
      (lock-rule)
      (role ?app [k application] (spatial ?app held-by @self)
                                 {@self READ ?app /succ})
      (utility obligation)
      (effects (maintain-proposal {@self DESTROY-ENTITY ?app})))

    ; THE OFFER: an unanswered form, the man who wrote it, an unfilled seat of his kind.
    ; The gate is "am I already drafting a verdict of ANY kind to ANYBODY" - a live pipeline
    ; lookup, true while a draft is proposed OR running - so one letter is begun at a time
    ; and finished before the next; per-man it would begin one draft per applicant and stack
    ; them past the pipeline's task table (measured: t_task_util cap 16, August), and per-KIND
    ; a man could be offered and rejected in one round (measured: June 3, ten minutes apart).
    ; BEGIN-proposal, and this is the shape it exists for: the condition
    ; to start is not the condition to stop, a maintained proposal would be reaped the
    ; instant its own gate went false, and draft-verdict concludes itself - no twin rung.
    ; A promise is a state of the SEAT: while {?job offered-to ?} stands, that seat is
    ; offered to nobody else; the acceptance spends it. The verdict carries the seat, so
    ; the same man is answered once per seat he asked for.
    (try
      (lock-rule)
      ; THE MAN who asked for a seat of this org that still stands open, is promised to no
      ; one, and has not been answered about it: ONE role. The seat is HIS filter's own free
      ; var, never a second role: a filter that names another role's var is a join, and a
      ; join admits nobody here (measured twice, the second role cast first or last, while
      ; the same filters as one role admit every man as his form is read).
      (role ?p [k human] {?p apply-for ?job /succ}
                         {?job org ?org}
                         -{? job ?job}
                         -{?job offered-to ?}
                         -{@self draft-verdict ?p ?job /succ})
      (when (not (proposed {@self draft-verdict ? ?})))
      (utility obligation)
      (effects (begin-proposal {@self draft-verdict ?p ?job})))

    ; THE REJECTION: the seat he asked for is held, and he was never answered about it.
    (try
      (lock-rule)
      (role ?p [k human] {?p apply-for ?job /succ}
                         {?job org ?org}
                         {? job ?job}
                         -{@self draft-verdict ?p ?job /succ})
      (when (not (proposed {@self draft-verdict ? ?})))
      (utility obligation)
      (effects (begin-proposal {@self draft-verdict ?p ?job})))

    ; A MAN AT THE COUNTER: his accept-job-offer is observable - running, or concluded the
    ; moment he announced himself, which is why it reads /ever - and he has named himself.
    ; Speaking to someone present tops the band outright: he gets his answer before the
    ; ledger does. ONE man at a time: twelve offerees walked in on one morning and twelve
    ; hire-applicant tasks fanned out at once (measured: the 16-slot competing table). A man
    ; already answered is done with: his errand stays observable until he is next perceived,
    ; and the counter told him his seat was his three times while a woman waited (measured).
    ; The record is this task's OWN conclusion, never the seat: HIRE fills the seat while the
    ; task still runs, and a role that stops admitting him withdraws it before the word.
    (try
      (lock-rule)
      (role ?man [k human] {?man accept-job-offer ?job /ever}
                           {?man name ?}
                           -{@self hire-applicant ?man ? /succ}
                           -{@self hire-applicant ?man ? /fail}
                           (spatial ?man co-located @self))
      (utility obligation always-pick)
      (effects (maintain-proposal {@self hire-applicant ?man ?job})))

    ; THE DAY IS OVER. The window includes starts-soon because the duty is proposed while
    ; the officer is still at home. The job is the one AT THIS ORG - an actor holds plural
    ; jobs by design, and a bare {@self job ?job} would read a stranger's shift.
    (try
      (role ?job {@self job ?job}
                 {?job org ?org})
      (when (table-match weekday_hours_label weekday (now-weekday) label ?tl)
            (latch-eval (any {?job ?tl ?}): ?sh-rel (bind ?sh-rel.target ?start) (bind ?sh-rel.auxiliary ?end))
            (not (or (in-work-hours ?start ?end) (work-starts-soon ?start ?end))))
      (effects
        (set-outcome ?rec-rel /succ)))))
