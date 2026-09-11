; ----------------------------------------------------------------------------
; recruit-staff ?org - the PERFORMANCE of the held recruit-staff duty ({@self duty-to ?org
; recruit-staff} is the obligation; the running task is doing it). Spawned by the running
; work task while the wage book shows an open line or a notice of the org's still stands,
; and concluded EVERY DAY - a duty that can only end when the book is full never ends, and
; a task that never ends keeps its actor busy and eats every same-band bid behind it.
;
; The officer's order of business, and every rung of it is PER POST: he reasons about the
; posts on his own book, one job object each, never about an org-level summary.
;   (0) read the book - ONE job object per ledger line, carrying {?job filled-by <holder>}
;       exactly where the line names one. Every rung below reads what he now KNOWS,
;       never what this task instance has done: /caused_by asks "did I post this through
;       THIS run", which re-posts yesterday's opening and cannot span a shift.
;   (1) an open job with no notice up    -> post-ad ?org ?job
;   (2) a filled job with a notice up    -> remove-ad ?org ?job
;  (2b) an offer left unanswered 180 d   -> the offer lapses, the job reopens
; (2b2) a seat standing offered to a man -> keep watching for him, so the day he
;       walks in @self knows him for the applicant rather than a second stranger
;  (2d) a man come for a job now taken   -> tell him so, and he goes
;   (3) work the applications: the office round (enter the premises, collect the
;       office post's applications), READ each, and hand the forms still in hand to
;       resolve-applications. The PAPER is the queue - @self believes nothing whatever
;       about a man he has not met.
;   (4) the shift that spawned the round ends it.
; ----------------------------------------------------------------------------

(npc-task {@self recruit-staff ?org}:?rec-rel
  ; OBSERVABLE, and for the WHOLE SHIFT: a man keeping the hiring book does it in the open,
  ; so anyone in the room reads the duty off him - that is how an applicant identifies the
  ; officer, the way you identify the bartender by the bartending. The ?org param is
  ; mental-only and cannot externalize; an onlooker sees it as @unknown, which is exactly
  ; what he knows - a man recruiting, for he-cannot-tell-whom.
  (obs)
  (track-skill-level [k personnel])
  (tar org)
  (and
    ; (0) THE BOOK, re-read on every run of the round: hires and departures rewrite the
    ; paper, and this read is the only thing that moves the officer's picture with it.
    ; ONE job object per LINE, and the ledger line IS its identity - so the object
    ; survives the holder coming and going, and every other mind reading this same page
    ; lands on that object instead of inventing a second one for the seat. filled-by is
    ; the whole of what the cell says; who holds what from the MAN's end is read-roster's
    ; quarterly job, not this daily one.
    (try
      ; The book, as a role: with no register belief there is simply no activation.
      (role ?reg {?org employee-register ?reg})
      (effects
        (for-each-row (attr ?reg writing) [/job-id ?line] [/worker ?worker-name] [/job ?jk]
          (o ?jk {@o org ?org} {@o job-id ?line}): ?job
          (begin-belief {?job org ?org})
          (begin-belief {?job job-id ?line})
          ; The cell holds the man's NAME, which is all a page can carry. Resolving it is what
          ; turns the line into an occupancy fact about a PERSON - imagined until the officer
          ; has met him, and fused with the man himself by identity_by_name. Resolved INSIDE
          ; the guard: a vacant line names nobody, and (o ..) on no name is not a query.
          (if (substantial ?worker-name)
              (then (o [k human] {@o name ?worker-name}): ?worker
                    (begin-belief {?job filled-by ?worker}))
              (else (for-each ?frel (every {?job filled-by ?})
                      (end-belief ?frel)))))))

    ; (1) POST A NOTICE for an open post that has none. One activation per open post, so
    ; an org with two distinct openings advertises both.
    (try
      ; ONE posting at a time: the lock admits a single activation, and it releases when
      ; that activation retires - which is when the notice goes up and -{?org display-ad
      ; ?job} falls. The next open post is admitted then. Without it both open posts are
      ; posted CONCURRENTLY on one body: both instances propose CREATE-ENTITY, one sheet
      ; comes out, and both WRITE that same sheet - two posts marked advertised, one notice
      ; standing (measured: instances B423/B424 both concluded on sheet o85).
      (lock-rule)
      ; -{?job filled-by ?} is what keeps @self's OWN seat out of this: his job is a ledger
      ; line like every other, and it is filled - by him. (It used to take a job-id
      ; filter, back when his own seat was a second object with no line at all.)
      (role ?job {?job org ?org}
                  {?job job-id ?}
                  -{?job filled-by ?}
                  -{?org display-ad ?job})
      (utility obligation)
      (effects (maintain-proposal {@self post-ad ?org ?job})))

    ; (2) TAKE THE NOTICE DOWN for a post that has since been filled.
    (try
      (role ?job {?job org ?org}
                  {?job job-id ?}
                  {?job filled-by ?}
                  {?org display-ad ?job})
      (utility obligation)
      (effects (maintain-proposal {@self remove-ad ?org ?job})))

    ; (2b) AN OFFER NOBODY TOOK UP LAPSES. {?job offered-to ?applicant} holds the seat out
    ; of open-job-for, so a man who never comes would shut it for good and every later
    ; applicant of that kind would be rejected by ABSENCE, indistinguishable from a full
    ; book. -{?job filled-by ?} makes it right in both directions: while the post is filled
    ; the offer is spent already, and the day the holder leaves and rung (0) ends filled-by,
    ; a long-past offer lapses on the next round and the seat reopens.
    (try
      (role ?job {?job org ?org}
                  {?job job-id ?}
                  -{?job filled-by ?})
      (role ?applicant {?job offered-to ?applicant})
      ; BIND THE QUERY ONCE. Spelled inline - (abs-seconds (any {..}).start) - the elapsed
      ; test passed on a one-second-old offer, so every fresh offer lapsed the instant it
      ; was made and the verdict round re-made it: two rules eating each other, 145 lapses
      ; a year and the deliberation never quiescing.
      (when (and (any {?job offered-to ?applicant}): ?orel
                 (abs-seconds ?orel.start): ?ostart
                 (now-abs-seconds): ?onow
                 (>= (/ (- ?onow ?ostart) 86400) (offer-lapse-days))))
      (effects
        (end-belief {?job offered-to ?applicant})
        (set-reconcilable ?applicant @false)))

    ; (2b2) KEEP WATCHING FOR THE MAN WHO WAS OFFERED THE SEAT. He exists in @self's
    ; mind only as the name on an application - ungrounded, a man he has heard of and
    ; never met. The day he walks in, perception mints a SECOND object for him, and
    ; the two only fuse if the paper one is in the RECONCILE set at that moment -
    ; the set of ungrounded objects worth comparing, which is not the perception
    ; attention set and has nothing to do with looking at anything.
    ;
    ; It is not, by default: the paper applicant is draft-verdict's target, so the
    ; pipeline disarms him the moment that task ends - months before he arrives. This
    ; rung re-arms him every round for as long as the offer stands, which is precisely
    ; the window in which he might come. Arming is idempotent and the lapse rung above
    ; is what lets go, so the set stays the size of the outstanding offers.
    (try
      (role ?job {?job org ?org}
                 {?job job-id ?}
                 -{?job filled-by ?})
      (role ?applicant {?job offered-to ?applicant})
      (effects (set-reconcilable ?applicant @true)))

    ; (2c) TAKE A MAN ON. Someone is standing in front of @self who has come to accept a
    ; post - his accept-job-offer is observable, so @self reads the errand off him, the way
    ; anyone reads a stranger's business from what he is plainly doing - he has NAMED
    ; himself, and the book shows a vacant line of that kind. Sign him on, and tell him so.
    ;
    ; His NAME is part of the admission, not a detail: the book records a name, so a man
    ; @self cannot name cannot be written onto it (HIRE checks exactly that). Until he
    ; announces himself he is a stranger standing in the room. The POST is hers to give,
    ; so the writing is HER act; a man who comes for a post already taken finds no vacant
    ; line and is turned away below - first come, first served.
    (try
      (role ?applicant [k human] {?applicant accept-job-offer ?jk ?}
                                 {?applicant name ?}
                                 (spatial ?applicant co-located @self))
      (role ?job {?job org ?org}
                  {?job job-id ?}
                  -{?job filled-by ?})
      (when (is-a ?job ?jk))
      (utility obligation always-pick)
      ; The book and her own picture move TOGETHER: the act that fills the seat concludes
      ; into the belief that it is filled. Left to the next book read, her beliefs lag the
      ; page by a round and she turns away the man she has just signed on.
      ;
      ; The ACT takes the post's KIND - a physical primitive's fields are physical,
      ; literal or spatial, and a job is none of those. The POSTLUDE takes the job
      ; OBJECT, and may: a belief can be about a seat on a page, an act cannot be
      ; performed on one.
      (effects (maintain-proposal {@self HIRE ?applicant ?jk}:?hire
                 [/postlude (begin-belief {?job filled-by ?applicant})])))

    ; The WORD that concludes his errand: he is taken on. HIRE has written him onto the
    ; book and minted the occupancy fact; now she says it to his face, naming the seat by
    ; DESCRIPTION (a job has no name of its own - the org and the ledger line are what
    ; make it THAT seat). The message QUOTES, so the (o ..) rides as a container and is
    ; resolved in HIS mind against his own objects. Told once: the SAY record is the guard.
    (try
      (role ?applicant [k human] {?applicant accept-job-offer ?jk ?}
                                 (spatial ?applicant co-located @self))
      (role ?job {?job org ?org}
                  {?job job-id ?line}
                  {?job filled-by ?applicant})
      (when (is-a ?job ?jk))
      (utility obligation always-pick)
      (effects
        (utterable-msg {(o ?jk {@o org ?org} {@o job-id ?line}) filled-by @you}): ?msg
        (if (and ?msg -{@self SAY ?msg ?applicant})
            (then (maintain-proposal {@self SAY ?msg ?applicant})))))

    ; (2d) TURN A MAN AWAY. He has come to accept a post - read off the man himself - and
    ; the book shows no open line of that kind: another applicant reached the office first.
    ; Say who holds it, and he goes; he is standing in front of @self, so there is nobody
    ; to write to and nothing to post. Speaking to someone present tops the band outright
    ; (always-pick): a man waiting on an answer gets it before the ledger.
    (try
      (role ?applicant [k human] {?applicant accept-job-offer ?jk ?}
                                 (spatial ?applicant co-located @self))
      (role ?job {?job org ?org}
                  {?job job-id ?line}
                  {?job filled-by ?holder})
      (when (and (is-a ?job ?jk)
                 (!= ?holder ?applicant)
                 (unsubstantial (open-job-for ?org ?jk))))
      (utility obligation always-pick)
      (effects
        (utterable-msg {(o ?jk {@o org ?org} {@o job-id ?line}) filled-by ?holder}): ?msg
        (if (and ?msg -{@self SAY ?msg ?applicant})
            (then (maintain-proposal {@self SAY ?msg ?applicant})))))

    ; (3) THE OFFICE ROUND. It waits on a STANDING notice, not on this run's posting: an
    ; application only exists in answer to one, and the notice outlives the shift that put
    ; it up. Without the wait the round holds the obligation band from the moment the duty
    ; starts and the posting rung - a sibling at the same band - never gets a turn, so the
    ; officer can never leave to post the opening he is waiting on. The office post is
    ; collect-applications - the officer's OWN sweep of the workplace stack, never the
    ; home read-mail (which keeps only letters addressed to him).
    (try
      (role ?wp {?org workplace ?wp})
      (when (and {?org display-ad ?}
                 (not (spatial @self building ?wp))
                 (>= (days-since-last {@self collect-applications ?wp /succ}) 1)))
      (utility obligation)
      (effects (maintain-proposal {@self enter ?wp})))
    (try
      (lock-rule)
      (when (and {?org workplace ?wp}
                 {?org display-ad ?}
                 (spatial @self building ?wp)
                 (>= (days-since-last {@self collect-applications ?wp /succ}) 1)))
      (utility obligation)
      (effects (maintain-proposal {@self collect-applications ?wp})))
    ; READ each held application FORM. Reading is ALL that happens: @self mints nothing
    ; about the man. Until he walks in he is a name on a sheet of paper, and a sheet of
    ; paper is what @self keeps.
    ;
    ; The PAPER is the queue. A clerk knows whom he owes an answer by the forms still in
    ; his hand - not by a belief that each of them is at this moment applying, which would
    ; be false (the man's apply-for concluded when he posted it, weeks ago) and unknowable
    ; (apply-for carries no (obs), so it can never be read off anybody). draft-verdict
    ; consumes the form once the answer to it is in the out-box.
    (try
      (role ?app [k application] (spatial ?app held-by @self)
            -{@self READ ?app /succ})
      (utility obligation)
      (effects (maintain-proposal {@self READ ?app})))
    ; RESOLVE the forms in hand: draft + mail a verdict for each.
    (try
      (lock-rule)
      (when (and (not (empty (spatial @self hold [k application])))
                 -{@self resolve-applications /succ /caused_by ?rec-rel}))
      (utility obligation)
      (effects
        (maintain-proposal {@self resolve-applications})))

    ; (4) THE DAY IS OVER. The window includes starts-soon because the duty is proposed
    ; while the officer is still at home: a bare out-of-hours test is TRUE then and would
    ; conclude the round before it has had a turn. The job is the one AT THIS ORG - an
    ; actor holds plural jobs by design, and a bare {@self job ?job} would read a
    ; stranger's shift.
    (try
      (role ?job {@self job ?job}
                 {?job org ?org})
      (when (table-match weekday_hours_label weekday (now-weekday) label ?tl)
            (latch-eval (any {?job ?tl ?}): ?sh-rel (bind ?sh-rel.target ?start) (bind ?sh-rel.auxiliary ?end))
            (not (or (in-work-hours ?start ?end) (work-starts-soon ?start ?end))))
      (effects
        (set-outcome ?rec-rel /succ)))))
