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

; APPLIED AND NEVER ANSWERED. An application older than 60 days, no offer held, no seat
; taken - and the vacancy he applied for still believed open: a rejection letter ENDS that
; vacancy belief (READ), so a man who was turned away does not admit here. The seat is a
; PICK, not an axis: two open seats of his kind are one unanswered application.
(npc-audit audit_unanswered_application
  (aspect labour)
  (cooldown 1 d)
  (role @self {@self apply-for ?job /succ}:?ap
              -{@self job ?}
              -{? offered-to @self}
              -{? job ?job})
  (when (>= (/ (- (now-abs-seconds) (abs-seconds ?ap.end)) 86400) 60))
  (effects
    (debug-print "labour audit: @self applied for ?job 60+ days ago and heard nothing")
    (expect @false "labour: applied 60+ days ago, no offer, no rejection, still jobless")))

; HIRED AND NEVER WORKED. A job held a window or more with no day's work concluded SINCE
; the hire: the last work ended before the job began, or there was none.
(npc-audit audit_hired_never_worked
  (aspect labour)
  (cooldown 1 d)
  (role @self {@self job ?job}:?j)
  (when (and (/ (- (now-abs-seconds) (abs-seconds ?j.start)) 86400): ?held-days
             (>= ?held-days 30)
             (>= (days-since-last {@self work ? /succ}) ?held-days)))
  (effects
    (debug-print "labour audit: @self has held ?job ?held-days days and concluded no day's work since")
    (expect @false "labour: held a job a month or more and concluded no day's work since the hire")))

; OFFERS OUTSTANDING AGAINST OPEN SEATS, per org the officer recruits for. An offer is a
; letter in the post and no reservation, so more offers than seats is a policy, not a bug -
; the count is what the policy gets ruled on; the expectation names the day it is exceeded.
; (cease-after-fire) + the cooldown is the explicit daily pulse: the count is re-taken
; every window.
(npc-audit audit_offers_vs_seats
  (aspect labour)
  (cooldown 1 d)
  (cease-after-fire)
  (role @self {@self duty-to ?org recruit-staff})
  (effects
    (bind 0 ?offers)
    (bind 0 ?open)
    (for-each ?jr (every {? org ?org})
      (bind ?jr.subject ?j)
      (if (and {?j job-id ?} -{? job ?j})
          (then (bind (+ ?open 1) ?open)
                (if {?j offered-to ?} (then (bind (+ ?offers 1) ?offers))))))
    (debug-print "labour audit: offers outstanding ?offers against open seats ?open")
    (expect (<= ?offers ?open) "labour: more offers outstanding than open seats")))

; TWO VERDICTS FOR ONE MAN ABOUT ONE SEAT. The officer answered the same application twice.
(npc-audit audit_two_verdicts_one_man
  (aspect labour)
  (cooldown 1 d)
  (role @self {@self duty-to ?org recruit-staff})
  (role ?p [k human] {@self draft-verdict ?p ?job /succ})
  (when (>= (count (every {@self draft-verdict ?p ?job /succ})) 2))
  (effects (expect @false "labour: two verdicts drafted for one applicant about one seat")))

; TWO APPLICATIONS IN FLIGHT. seek_apply_pick admits one at a time; a second means the lock
; or the /pres gate has failed. Gated on the running task, as a running act must be; the
; task's own push drives the re-evaluation.
(npc-audit apply-for_audit_two_in_flight
  (aspect labour)
  (task {@self apply-for ?job})
  (when (>= (count (every {@self apply-for ? /pres})) 2))
  (effects (expect @false "labour: two applications in flight at once")))
