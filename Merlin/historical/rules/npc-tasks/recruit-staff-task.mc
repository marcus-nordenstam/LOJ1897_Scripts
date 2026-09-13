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
;   a man at the counter-> hire-applicant ?man ?jk  (first through the door)
;   shift over          -> /succ
; Every rung reads what he now KNOWS - the beliefs the book and the forms put there -
; never what this task instance has done, which cannot span a shift.
; ----------------------------------------------------------------------------

(npc-task {@self recruit-staff ?org}:?rec-rel
  ; OBSERVABLE, and for the WHOLE SHIFT: a man keeping the hiring book does it in the open,
  ; so anyone in the room reads the duty off him - that is how an applicant identifies the
  ; officer, the way you identify the bartender by the bartending.
  (obs)
  (track-skill-level [k personnel])
  (tar org)
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
                 -{?job filled-by ?}
                 -{?org display-ad ?job})
      (utility obligation)
      (effects (maintain-proposal {@self post-ad ?org ?job})))

    ; TAKE THE NOTICE DOWN for a post that has since been filled.
    (try
      (role ?job {?job org ?org}
                 {?job job-id ?}
                 {?job filled-by ?}
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

    ; THE OFFER: an unanswered form, the man who wrote it, an unfilled seat of his kind.
    ; The gate is "am I already drafting an offer to ANYBODY" - a live pipeline lookup,
    ; true while a draft is proposed OR running - so one letter is begun at a time and
    ; finished before the next; per-man it would begin one draft per applicant and stack
    ; them past the pipeline's task table (measured: t_task_util cap 16, August). BEGIN-proposal, and this is the shape it exists for: the condition
    ; to start is not the condition to stop, a maintained proposal would be reaped the
    ; instant its own gate went false, and draft-verdict concludes itself - no twin rung.
    ; NOTHING is pencilled against the seat here: a promise is a letter in the post plus
    ; the book's note of it (draft-verdict writes both); two men may be written to, and
    ; the first through the door is hired.
    (try
      (lock-rule)
      ; The MAN is the anchor: someone @self has heard of applying (a fact READ put there,
      ; so his form has been read) and not yet answered (only the draft burns a form, so it
      ; is still in hand). The SEAT is cast on HIS kind, and cast LAST: cast before the
      ; roles it shares no variable with, it admits nothing at all (measured: 0 vs 20).
      (role ?p [k human] {?p apply-for ?jk ? /succ}
                         -{@self draft-verdict ?p ? /succ})
      (role ?job ?jk {?job org ?org}
                     {?job job-id ?}
                     -{?job filled-by ?})
      (when (not (proposed {@self draft-verdict ? [k offer-letter]})))
      (utility obligation)
      (effects (begin-proposal {@self draft-verdict ?p [k offer-letter]})))

    ; THE REJECTION: no unfilled seat of his kind at all. Complementary to the offer by
    ; construction - an open seat of his kind, or none.
    (try
      (lock-rule)
      (role ?p [k human] {?p apply-for ?jk ? /succ}
                         -{@self draft-verdict ?p ? /succ})
      (when (and (unsubstantial (open-job-for ?org ?jk))
                 (not (proposed {@self draft-verdict ? [k rejection-letter]}))))
      (utility obligation)
      (effects (begin-proposal {@self draft-verdict ?p [k rejection-letter]})))

    ; A MAN AT THE COUNTER: his accept-job-offer is observable and he has named himself.
    ; Speaking to someone present tops the band outright: he gets his answer before the
    ; ledger does.
    (try
      (role ?man [k human] {?man accept-job-offer ?jk ?}
                           {?man name ?}
                           (spatial ?man co-located @self))
      (utility obligation always-pick)
      (effects (maintain-proposal {@self hire-applicant ?man ?jk})))

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
