; ----------------------------------------------------------------------------
; resolve-applications - the recruit officer's verdict round over the applicants he
; has learned of by READing their applications (each READ adopted a {?applicant
; apply-for ?jk} belief). ONE decision: the first applicant gets the post, remembered as
; {@self offered-post ?applicant ?jk} - a standing belief, because the drafting spans
; days and a fresh task instance must not offer the post again; every other applicant
; gets a rejection. Each draft-verdict envelopes + mails its verdict and ENDS that
; applicant's apply-for belief, so the unanswered set shrinks to empty; the round then
; spends its decision and concludes. The iteration and the offer-vs-reject decision live
; here; the drafting is the draft-verdict sub-task (composing the lego acts).
; ----------------------------------------------------------------------------

(npc-task {@self resolve-applications}:?rt-rel
  (track-skill-level [k personnel])
  (and
    (try
      (role @self -{@self offered-post ? ?})
      (role ?applicant {?applicant apply-for ?jk}
            (select (policy first-match)))
      (effects (begin-belief {@self offered-post ?applicant ?jk})))
    (try
      (role ?applicant {?applicant apply-for ?}
                       {@self offered-post ?applicant ?})
      (utility fallback)
      (effects
               (maintain-proposal {@self draft-verdict ?applicant [k offer-letter]})))
    (try
      (role ?offered {@self offered-post ?offered ?})
      (role ?applicant {?applicant apply-for ?}
                       (!= ?applicant ?offered)
                       (select (policy first-match)))
      (utility (above draft-verdict))
      (effects
               (maintain-proposal {@self draft-verdict ?applicant [k rejection-letter]})))
    (try
      (role @self {@self offered-post ? ?})
      (when -{? apply-for ?})
      (effects
        (for-each ?decision (every {@self offered-post ? ?})
          (end-belief ?decision))
        (set-outcome ?rt-rel /succ)))))
