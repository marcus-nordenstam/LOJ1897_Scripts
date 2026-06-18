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
;   hire_commit : completion (chain-only) - the eligibility-match hire + clears goal.
; ----------------------------------------------------------------------------

(hsim-event hire_go
  (intra-day)
  (nl   "@self sets out to seek work")
  (when (and (has-goal engage_staff)
             (not (self-at (articles-building (goal-focus engage_staff))))))
  (utility 82)
  (effects (go @self (articles-building (goal-focus engage_staff)))))

(hsim-event hire_dwell
  (intra-day)
  (nl   "@self applies for a post")
  (when (and (has-goal engage_staff)
             (self-at (articles-building (goal-focus engage_staff)))))
  (utility 82)
  (effects (act hire_commit 45)))

(hsim-event hire_commit
  (schedule (chain-only))
  (nl   "@self is hired")
  (effects
    (hire-matched :articles (goal-focus engage_staff) :worker @self)
    (clear-goal @self engage_staff)
    (log _hiring @self)))
