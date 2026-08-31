; ----------------------------------------------------------------------------
; resolve_applications - the recruit officer's verdict round over the applicants he
; has learned of by READing their applications (each READ adopted a {?applicant
; apply_for ?jk} belief). ONE at a time: the first gets an offer drafted, every later
; one a rejection; each draft_verdict envelopes + mails its verdict and ENDS that
; applicant's apply_for belief, so the unanswered set shrinks to empty and the round
; concludes. The iteration and the offer-vs-reject decision live here; the drafting is
; the draft_verdict sub-task (composing the lego acts).
; ----------------------------------------------------------------------------

(npc-task {@self resolve_applications}:?rt-rel
  (track-skill-level [k personnel])
  (and
    (try
      (role ?applicant {?applicant apply_for ?}
            (select (policy first-match)))
      (when (and -{@self draft_verdict ? [k offer_letter] /caused_by ?rt-rel /ever}
                 -{@self draft_verdict ?applicant ? /caused_by ?rt-rel /ever}))
      (utility fallback)
      (effects (debug-print "RSV_OFFER")
               (begin-proposal {@self draft_verdict ?applicant [k offer_letter]})))
    (try
      (role ?applicant {?applicant apply_for ?}
            (select (policy first-match)))
      (when (and {@self draft_verdict ? [k offer_letter] /caused_by ?rt-rel /ever}
                 -{@self draft_verdict ?applicant ? /caused_by ?rt-rel /ever}))
      (utility (above draft_verdict))
      (effects (debug-print "RSV_REJECT")
               (begin-proposal {@self draft_verdict ?applicant [k rejection_letter]})))
    (try
      (when -{? apply_for ?})
      (effects (debug-print "RSV_DONE") (set-outcome ?rt-rel /succ)))))
