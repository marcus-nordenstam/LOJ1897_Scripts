; ----------------------------------------------------------------------------
; recruit-staff ?org - the PERFORMANCE of the held recruit-staff duty ({@self duty-to ?org
; recruit-staff} is the obligation; the running task is doing it). Spawned by the running
; work task while the wage book shows an open line or a notice of the org's still stands,
; and concluded EVERY DAY - a duty that can only end when the book is full never ends, and
; a task that never ends keeps its actor busy and eats every same-band bid behind it.
;
; The officer's order of business, and every rung of it is PER POST: he reasons about the
; posts on his own book, one job object each, never about an org-level summary.
;   (0) read the book - one job object per line, carrying {?post filled-by <holder>}
;       exactly where the line names one. Every rung below reads what he now KNOWS,
;       never what this task instance has done: /caused_by asks "did I post this through
;       THIS run", which re-posts yesterday's opening and cannot span a shift.
;   (1) an open post with no notice up   -> post-ad ?org ?post
;   (2) a filled post with a notice up   -> remove-ad ?org ?post
;   (3) work the applications: the office round (enter the premises, read the morning
;       post), READ each application into a {?applicant apply-for ?jk} belief, consume
;       the paper, and hand the learned batch to resolve-applications.
;   (4) the shift that spawned the round ends it.
; ----------------------------------------------------------------------------

(npc-task {@self recruit-staff ?org}:?rec-rel
  (track-skill-level [k personnel])
  (tar org)
  (and
    ; (0) THE BOOK, re-read on every run of the round: hires and departures rewrite the
    ; paper, and this read is the only thing that moves the officer's picture with it.
    ; One job object per LINE - the line number is the post's identity, so the object
    ; survives the holder coming and going, which is what lets -{?post filled-by ?} be a
    ; standing fact about the POST rather than about the last man in it.
    (try
      (when (and {?org employee-register ?reg}
                 (check ?reg)))
      (effects
        (bind 0 ?line)
        (for-each-row (attr ?reg writing) [/worker ?worker] [/job ?jk]
          (bind (+ ?line 1) ?line)
          (o ?jk {@o org ?org} {@o post-no ?line}): ?post
          (begin-belief {?post org ?org})
          (begin-belief {?post post-no ?line})
          (if (substantial ?worker)
              (then (begin-belief {?post filled-by ?worker}))
              (else (for-each ?frel (every {?post filled-by ?})
                      (end-belief ?frel)))))))

    ; (1) POST A NOTICE for an open post that has none. One activation per open post, so
    ; an org with two distinct openings advertises both.
    (try
      ; ONE posting at a time: the lock admits a single activation, and it releases when
      ; that activation retires - which is when the notice goes up and -{?org display-ad
      ; ?post} falls. The next open post is admitted then. Without it both open posts are
      ; posted CONCURRENTLY on one body: both instances propose CREATE-ENTITY, one sheet
      ; comes out, and both WRITE that same sheet - two posts marked advertised, one notice
      ; standing (measured: instances B423/B424 both concluded on sheet o85).
      (lock-rule)
      ; post-no is what makes this a POST and not just any job object hanging off the org -
      ; @self's OWN job carries {job org ?org} too, and without the filter he posts a notice
      ; for his own seat (measured: the notice read "display-ad superintendent").
      (role ?post {?post org ?org}
                  {?post post-no ?}
                  -{?post filled-by ?}
                  -{?org display-ad ?post})
      (utility obligation)
      (effects (maintain-proposal {@self post-ad ?org ?post})))

    ; (2) TAKE THE NOTICE DOWN for a post that has since been filled.
    (try
      (role ?post {?post org ?org}
                  {?post post-no ?}
                  {?post filled-by ?}
                  {?org display-ad ?post})
      (utility obligation)
      (effects (maintain-proposal {@self remove-ad ?org ?post})))

    ; (3) THE OFFICE ROUND. It waits on a STANDING notice, not on this run's posting: an
    ; application only exists in answer to one, and the notice outlives the shift that put
    ; it up. Without the wait the round holds the obligation band from the moment the duty
    ; starts and the posting rung - a sibling at the same band - never gets a turn, so the
    ; officer can never leave to post the opening he is waiting on.
    (try
      (when (and {?org workplace ?wp}
                 {?org display-ad ?}
                 (not (spatial @self building ?wp))
                 (>= (days-since-last {@self read-mail ?wp /succ}) 1)))
      (utility obligation)
      (effects (maintain-proposal {@self enter ?wp})))
    (try
      (lock-rule)
      (when (and {?org workplace ?wp}
                 {?org display-ad ?}
                 (spatial @self building ?wp)
                 (>= (days-since-last {@self read-mail ?wp /succ}) 1)))
      (utility obligation)
      (effects (begin-proposal {@self read-mail ?wp})))
    ; READ each held application - adopt its {?applicant apply-for ?jk} - then consume it.
    (try
      (role ?app [k application] (spatial @self hold)
            -{@self READ ?app /succ})
      (utility obligation)
      (effects (maintain-proposal {@self READ ?app})))
    (try
      (role ?app [k application] (spatial @self hold)
            (any {@self READ ?app /succ}))
      (effects (maintain-proposal {@self DESTROY-ENTITY ?app})))
    ; RESOLVE the learned applicants: draft + mail a verdict to each.
    (try
      (lock-rule)
      (when (and {? apply-for ?}
                 (empty (spatial @self hold [k application]))
                 -{@self resolve-applications /pres}))
      (utility obligation)
      (effects (begin-proposal {@self resolve-applications})))

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
      (effects (set-outcome ?rec-rel /succ)))))
