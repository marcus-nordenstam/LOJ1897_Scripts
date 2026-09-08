; ----------------------------------------------------------------------------
; resolve-applications - the recruit officer's verdict round over the applicants he
; has learned of by READing their applications (each READ adopted a {?applicant
; apply-for ?jk} belief). ONE decision per OPEN POST: the first applicant for its kind
; gets it, remembered as {@self offered-post ?applicant ?post} - a STANDING belief,
; never spent: the post is filled by the take-up and is not offered again here. An
; applicant offered nothing is rejected once no open post of his kind remains
; un-offered (open-post-for). Each draft-verdict envelopes + mails its verdict and
; ENDS that applicant's apply-for belief, so the unanswered set shrinks to empty and
; the round concludes. The drafting is the draft-verdict sub-task (composing the lego
; acts).
; ----------------------------------------------------------------------------

(npc-task {@self resolve-applications}:?rt-rel
  (track-skill-level [k personnel])
  (and
    (try
      (role ?org {@self duty-to ?org recruit-staff})
      (role ?post {?post org ?org}
                 {?post post-no ?}
                 -{?post filled-by ?}
                 -{@self offered-post ? ?post})
      (role ?applicant {?applicant apply-for ?jk /pres}
                       -{@self offered-post ?applicant ?})
      (when (is-a ?post ?jk))
      (effects (begin-belief {@self offered-post ?applicant ?post})))
    (try
      (role ?applicant {?applicant apply-for ?jk /pres}
                       {@self offered-post ?applicant ?})
      (utility fallback)
      (effects
               (maintain-proposal {@self draft-verdict ?applicant [k offer-letter]})))
    (try
      (lock-rule)
      (role ?org {@self duty-to ?org recruit-staff})
      (role ?applicant {?applicant apply-for ?jk /pres}
                       -{@self offered-post ?applicant ?})
      (when (unsubstantial (open-post-for ?org ?jk)))
      (utility (above draft-verdict))
      (effects
               (maintain-proposal {@self draft-verdict ?applicant [k rejection-letter]})))
    (try
      (when -{? apply-for ? /pres})
      (effects (set-outcome ?rt-rel /succ)))))
