; ----------------------------------------------------------------------------
; resolve-applications - the recruit officer's verdict round over the applicants he
; has learned of by READing their applications (each READ adopted a {?applicant
; apply-for ?jk} belief). ONE decision per OPEN POST: the first applicant for its kind
; gets it, pencilled against the LINE as {?job offered-to ?applicant} - a state of the
; seat, which the acceptance spends and a lapse clears. An
; applicant offered nothing is rejected once no open post of his kind remains
; un-offered (open-job-for). Each draft-verdict envelopes + mails its verdict and
; ENDS that applicant's apply-for belief, so the unanswered set shrinks to empty and
; the round concludes. The drafting is the draft-verdict sub-task (composing the lego
; acts). Both drafting rungs take the lock and answer ONE applicant at a time: two drafts
; of the same verdict at once propose the very same create-a-letter act, and one letter
; cannot answer two men.
; ----------------------------------------------------------------------------

(npc-task {@self resolve-applications}:?rt-rel
  (track-skill-level [k personnel])
  (and
    (try
      (role ?org {@self duty-to ?org recruit-staff})
      (role ?job {?job org ?org}
                 {?job job-id ?}
                 -{?job filled-by ?}
                 -{?job offered-to ?})
      ; ONE offer per man in flight: a seat already promised to him is not promised twice.
      (role ?applicant {?applicant apply-for ?jk /pres}
                       -{? offered-to ?applicant})
      (when (is-a ?job ?jk))
      (effects (begin-belief {?job offered-to ?applicant})))
    (try
      (lock-rule)
      ; A man with a seat standing offered to him. Read from HIS end, so it is the same
      ; question the rejection rung asks and neither casts a role it does not use.
      (role ?applicant {?applicant apply-for ?jk /pres}
                       {? offered-to ?applicant})
      (utility fallback)
      (effects
               (maintain-proposal {@self draft-verdict ?applicant [k offer-letter]})))
    (try
      (lock-rule)
      (role ?org {@self duty-to ?org recruit-staff})
      (role ?applicant {?applicant apply-for ?jk /pres}
                       -{? offered-to ?applicant})
      (when (unsubstantial (open-job-for ?org ?jk)))
      (utility (above draft-verdict))
      (effects
               (maintain-proposal {@self draft-verdict ?applicant [k rejection-letter]})))
    (try
      (when -{? apply-for ? /pres})
      (effects (set-outcome ?rt-rel /succ)))))
