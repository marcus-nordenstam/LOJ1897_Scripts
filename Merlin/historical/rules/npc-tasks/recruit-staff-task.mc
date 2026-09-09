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
;  (2d) a man come for a job now taken   -> tell him so, and he goes
;   (3) work the applications: the office round (enter the premises, collect the
;       office post's applications), READ each into a {?applicant apply-for ?jk} belief, consume
;       the paper, and hand the learned batch to resolve-applications.
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
        (for-each-row (attr ?reg writing) [/line ?line] [/worker ?worker] [/job ?jk]
          (o ?jk {@o org ?org} {@o job-ledger-line-no ?line}): ?job
          (begin-belief {?job org ?org})
          (begin-belief {?job job-ledger-line-no ?line})
          (if (substantial ?worker)
              (then (begin-belief {?job filled-by ?worker}))
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
      ; line like every other, and it is filled - by him. (It used to take a job-ledger-line-no
      ; filter, back when his own seat was a second object with no line at all.)
      (role ?job {?job org ?org}
                  {?job job-ledger-line-no ?}
                  -{?job filled-by ?}
                  -{?org display-ad ?job})
      (utility obligation)
      (effects (maintain-proposal {@self post-ad ?org ?job})))

    ; (2) TAKE THE NOTICE DOWN for a post that has since been filled.
    (try
      (role ?job {?job org ?org}
                  {?job job-ledger-line-no ?}
                  {?job filled-by ?}
                  {?org display-ad ?job})
      (utility obligation)
      (effects (maintain-proposal {@self remove-ad ?org ?job})))

    ; (2b) AN OFFER NOBODY TOOK UP LAPSES. {@self offered-post ?applicant ?job} is a
    ; standing belief the take-up never spends, and open-job-for excludes any post
    ; carrying one - so a stale offer holds the seat shut and every later applicant of
    ; that kind is rejected by ABSENCE, indistinguishable from a genuinely full book.
    ; -{?job filled-by ?} is what makes it right in both directions: while the post is
    ; filled the offer is harmless, and the day the holder leaves and rung (0) ends
    ; filled-by, the long-past offer lapses on the next round and the seat reopens.
    (try
      (role ?job {?job org ?org}
                  {?job job-ledger-line-no ?}
                  -{?job filled-by ?})
      (role ?applicant {@self offered-post ?applicant ?job})
      (when (>= (/ (- (now-abs-seconds)
                      (abs-seconds (any {@self offered-post ?applicant ?job}).start))
                   86400)
                (offer-lapse-days)))
      (effects
        (for-each ?orel (every {@self offered-post ?applicant ?job})
          (end-belief ?orel))))

    ; (2c) TAKE A MAN ON. Someone is standing in front of @self who has come to take up a
    ; post - his take-up-post is observable, so @self reads the errand off him, no word
    ; spoken - and the book still shows a vacant line of that kind. Sign him on.
    ;
    ; The POST is his to give, so the writing is HIS act, not the applicant's. A man who
    ; comes for a post already taken simply finds no vacant line and is not written down:
    ; first come, first served, and the establishment never grows past its own book.
    (try
      (role ?applicant [k human] {?applicant take-up-post ?jk ?}
                                 (spatial ?applicant co-located @self))
      (role ?job {?job org ?org}
                  {?job job-ledger-line-no ?}
                  -{?job filled-by ?})
      (when (is-a ?job ?jk))
      (utility obligation)
      (effects (maintain-proposal {@self HIRE ?applicant ?jk})))

    ; (2d) TURN A MAN AWAY. He has come for a post - his take-up-post says so, read off the
    ; man himself - and the book shows no open line of that kind: another applicant reached
    ; the office first. Say which post is taken and who holds it. He is standing in front of
    ; @self, so there is nobody to write to and nothing to post; the man hears it, and that
    ; is what ends his errand. The post named is the one the NOTICE named, which is how he
    ; can tell it is his.
    (try
      (role ?applicant [k human] {?applicant take-up-post ?jk ?}
                                 (spatial ?applicant co-located @self))
      (role ?job {?job org ?org}
                  {?job job-ledger-line-no ?}
                  {?job filled-by ?holder})
      (when (and (is-a ?job ?jk)
                 (unsubstantial (open-job-for ?org ?jk))))
      (utility obligation)
      (effects
        (utterable-msg {?job filled-by ?holder}): ?msg
        (if ?msg
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
    ; READ each held application FORM: who (by name), where they live (by address), for
    ; which post - the applicant becomes {?applicant apply-for ?jk} in @self's mind, the
    ; applicant's address rides on the applicant - then consume the paper.
    (try
      (role ?app [k application] (spatial ?app held-by @self)
            -{@self READ ?app /succ})
      (utility obligation)
      (effects (maintain-proposal {@self READ ?app})))
    (try
      (role ?app [k application] (spatial ?app held-by @self)
            {@self READ ?app /succ})
      (effects
        (tolerate (attr ?app writing): ?form)
        (tolerate (table-match ?form field applicant value ?applicant-name))
        (tolerate (table-match ?form field home value ?applicant-address))
        (tolerate (table-match ?form field job value ?applied-jk))
        (if (and (substantial ?applicant-name) (substantial ?applicant-address) (substantial ?applied-jk))
            (then
              (o [k human] {@o name ?applicant-name} {@o address ?applicant-address}): ?applicant
              (if -{?applicant apply-for ?applied-jk}
                  (then (begin-belief {?applicant apply-for ?applied-jk})))))
        (maintain-proposal {@self DESTROY-ENTITY ?app})))
    ; RESOLVE the learned applicants: draft + mail a verdict to each.
    (try
      (lock-rule)
      (when (and {? apply-for ? /pres}
                 (empty (spatial @self hold [k application]))
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
