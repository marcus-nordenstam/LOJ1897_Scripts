; ----------------------------------------------------------------------------
; apprentice_errand - the npc-ACT half of the apprenticeship split (Item 5).
;
; The decision (apprenticeship.hs `apprenticeship_start`) minted {@self goal
; {@self seek_indenture <master_articles>}}. The youth presents himself at the
; master's premises and is taken on there - the indenture + the master bond struck
; in person. The master's articles are the goal focus, so the premises are
; (articles-building (goal-focus seek_indenture)) and the master is
; (org-founder (goal-focus seek_indenture)).
;
;   indenture_go     : hold the goal, not at the master's premises -> travel act.
;   indenture_dwell  : hold the goal, AT the premises -> a dwell (being taken on).
;   indenture_commit : completion (chain-only) - hires the youth as a trainee clerk,
;                      mints the {@self master <master>} bond, clears the goal.
; ----------------------------------------------------------------------------

(hsim-event indenture_go
  (intra-day)
  (nl   "@self sets out to be apprenticed")
  (when (and (has-goal seek_indenture)
             (not (self-at (articles-building (goal-focus seek_indenture))))))
  (utility 80)
  (effects (go @self (articles-building (goal-focus seek_indenture)))))

(hsim-event indenture_dwell
  (intra-day)
  (nl   "@self presents himself to a master")
  (when (and (has-goal seek_indenture)
             (self-at (articles-building (goal-focus seek_indenture)))))
  (utility 80)
  (effects (act indenture_commit 90)))

(hsim-event indenture_commit
  (schedule (chain-only))
  (nl   "@self is apprenticed")
  (effects
    (hire :articles (goal-focus seek_indenture) :worker @self :role clerk :level trainee)
    (begin-belief @self master (org-founder (goal-focus seek_indenture)))
    (clear-goal @self seek_indenture)
    (log _apprenticeship @self)))
