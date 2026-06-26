; ----------------------------------------------------------------------------
; hire_errand - the npc-ACT half of the hiring split (Item 5, employee-side).
;
; The decision (employment.hs `hiring`) minted {@self goal {@self engage_staff
; <org_articles>}} on the WORKER. He presents himself at the firm and is engaged
; there - the hiring conducted in person at the premises. The org's articles are
; the goal focus, so the firm is (articles-building (goal-focus engage_staff)) and
; the eligibility-match hire uses those articles directly.
;
;   hire_go     : hold the goal, not at the firm -> travel act to its premises.
;   hire_dwell  : hold the goal, AT the firm -> a short dwell (the interview).
;   hire_commit : completion (completion-only) - the eligibility-match hire + clears goal.
; ----------------------------------------------------------------------------

(hsim-event hire_go
  (intra-day)
  (when (and (articles-building (goal-focus engage_staff) ?venue)
             (has-goal engage_staff)
             (not (at-place ?venue))))
  (utility 82)
  (effects (go @self ?venue)))

(hsim-event hire_dwell
  (intra-day)
  (when (and (articles-building (goal-focus engage_staff) ?venue)
             (has-goal engage_staff)
             (at-place ?venue)))
  (utility 82)
  (effects (act hire_commit 45)))

(hsim-event hire_commit
  (schedule (completion-only))
  ; bind the org's articles to a plain ?var so it can serve as a {pattern} subject
  ; inside hire-seq (a macro arg used in a pattern must be a ?var, not an expr).
  (let ((?art (goal-focus engage_staff)))
    (effects
      ; eligibility MATCH (C++: occupation catalog + career scan) binds ?jk = the
      ; matched scoped job kind ([k job <leaf>]) or @fail (a marginal fit may not be
      ; taken); the .hs hire-seq then mints the employment beliefs in @self's mind.
      (match-job :articles ?art :worker @self (bind ?jk))
      (if ?jk
        (hire-seq ?art ?jk [k apprentice]))
      (clear-goal @self engage_staff)
      )))
