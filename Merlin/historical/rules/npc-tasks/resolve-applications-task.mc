; ----------------------------------------------------------------------------
; resolve-applications - the recruit officer's verdict round over the applicants he
; has learned of by READing their applications (each READ adopted a {?applicant
; apply-for ?jk} belief). ONE at a time: the first gets an offer drafted, every later
; one a rejection; each draft-verdict envelopes + mails its verdict and ENDS that
; applicant's apply-for belief, so the unanswered set shrinks to empty and the round
; concludes. The iteration and the offer-vs-reject decision live here; the drafting is
; the draft-verdict sub-task (composing the lego acts).
; ----------------------------------------------------------------------------

(npc-task {@self resolve-applications}:?rt-rel
  (track-skill-level [k personnel])
  (and
    (try
      (role ?applicant {?applicant apply-for ?}
            (select (policy first-match)))
      (when (and -{@self draft-verdict ? [k offer-letter] /caused_by ?rt-rel /ever}
                 -{@self draft-verdict ?applicant ? /caused_by ?rt-rel /ever}))
      (utility fallback)
      (effects
               (begin-proposal {@self draft-verdict ?applicant [k offer-letter]})))
    (try
      (role ?applicant {?applicant apply-for ?}
            (select (policy first-match)))
      (when (and {@self draft-verdict ? [k offer-letter] /caused_by ?rt-rel /ever}
                 -{@self draft-verdict ?applicant ? /caused_by ?rt-rel /ever}))
      (utility (above draft-verdict))
      (effects
               (begin-proposal {@self draft-verdict ?applicant [k rejection-letter]})))
    (try
      (when -{? apply-for ?})
      (effects (set-outcome ?rt-rel /succ)))))
