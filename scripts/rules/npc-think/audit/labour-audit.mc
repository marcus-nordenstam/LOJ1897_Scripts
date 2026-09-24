; ----------------------------------------------------------------------------
; labour-audit - the cross-task expectations of the labour aspect. Each rule admits ONE
; pathological state that no single task can see from inside itself, and does nothing but
; count it: (expect @false ..) is one count per (rule, message) in the --lint-profile dump,
; rendered by merlin-lint as expectation-failed. No proposals, no beliefs written, and the
; whole file is skipped unparsed by a shipping build (npc-audit). A rule with a standing (when) fires ONCE per
; admitted binding and holds, so each count is one pathological instance, not one day.
; hsim simulates ONE day per monthly window, so every age here is a month or more: a
; days-since-last read is ~30 at every window start.
; ----------------------------------------------------------------------------

; AN APPLICATION NO RUNG CAN ANSWER. Read from the OFFICER's side, because she is the one
; who can see it: she holds his application, has not answered it, and NEITHER rung that
; answers an applicant can admit him. The offer rung wants a seat promised to nobody; the
; rejection rung wants a seat somebody holds. A seat that is promised AND held by nobody
; satisfies neither, so he waits for ever - not because she is busy, but because nothing in
; the corpus can ever reach him. The promise is spent by an acceptance and by nothing else,
; so an offeree who never presents himself strands every later applicant behind him.
;
; NOT a waiting-time test. The rungs answer one man at a time by design, so a man waiting
; his turn is ordinary, and a calendar threshold measures hsim's cadence rather than the
; corpus: at one simulated day a month, sixty days is two days of the officer's working
; life. This admits the SHAPE that cannot resolve, whatever the clock says.
(npc-audit audit_application_unanswerable
  (aspect labour)
  (cooldown 1 d try-once)
  ; The org is a ROLE, not a var taken off the first duty belief: an officer may keep more
  ; than one book, and each book's seats are its own.
  (role ?org {@self duty-to ?org recruit-staff}
    (role ?p [k human] {?p apply-for ?job /succ}
                       {?job org ?org}
                       -{@self draft-verdict ?p ?job /succ}
                       -{? job ?job}
                       {?job offered-to ?}
      (effects
        (debug-print "labour audit: ?p applied for ?job - promised to another and held by nobody, so no rung answers him")
        (expect @false "labour: an application no rung can answer - its seat is promised to another and held by nobody")))))

; HIRED AND NEVER WORKED. A job held a window or more with no day's work concluded SINCE
; the hire: the last work ended before the job began, or there was none.
(npc-audit audit_hired_never_worked
  (aspect labour)
  (cooldown 1 d try-once)
  (role @self {@self job ?job}:?j
    (when (and (/ (- (now-abs-seconds) (abs-seconds ?j.start)) 86400): ?held-days
               (>= ?held-days 30)
               (>= (days-since-last {@self work ? /succ}) ?held-days)))
    (effects
      (debug-print "labour audit: @self has held ?job ?held-days days and concluded no day's work since")
      (expect @false "labour: held a job a month or more and concluded no day's work since the hire"))))

; OFFERS OUTSTANDING AGAINST OPEN SEATS, per org the officer recruits for. An offer is a
; letter in the post and no reservation, so more offers than seats is a policy, not a bug -
; the count is what the policy gets ruled on; the expectation names the day it is exceeded.
; (cease-after-fire) + the cooldown is the explicit daily pulse: the count is re-taken
; every window.
(npc-audit audit_offers_vs_seats
  (aspect labour)
  (cooldown 1 d try-once)
  (cease-after-fire)
  (role @self {@self duty-to ?org recruit-staff}
    (effects
      (bind 0 ?offers)
      (bind 0 ?open)
      (for-each ?jr (every {? org ?org})
        (bind ?jr.subject ?j)
        (if (and {?j job-id ?} -{? job ?j})
            (then (bind (+ ?open 1) ?open)
                  (if {?j offered-to ?} (then (bind (+ ?offers 1) ?offers))))))
      (debug-print "labour audit: offers outstanding ?offers against open seats ?open")
      (expect (<= ?offers ?open) "labour: more offers outstanding than open seats"))))

; TWO VERDICTS FOR ONE MAN ABOUT ONE SEAT. The officer answered the same application twice.
(npc-audit audit_two_verdicts_one_man
  (aspect labour)
  (cooldown 1 d try-once)
  (role @self {@self duty-to ?org recruit-staff}
    (role ?p [k human] {@self draft-verdict ?p ?job /succ}
      (when (>= (count (every {@self draft-verdict ?p ?job /succ})) 2))
      (effects (expect @false "labour: two verdicts drafted for one applicant about one seat")))))

; TWO APPLICATIONS IN FLIGHT. seek_apply_pick admits one at a time; a second means the lock
; or the /pres gate has failed. Gated on the running task, as a running act must be; the
; task's own push drives the re-evaluation.
(npc-audit apply-for_audit_two_in_flight
  (aspect labour)
  (task {@self apply-for ?job})
  (when (>= (count (every {@self apply-for ? /pres})) 2))
  (effects (expect @false "labour: two applications in flight at once")))
