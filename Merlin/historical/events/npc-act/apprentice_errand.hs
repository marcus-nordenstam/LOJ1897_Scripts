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
;   indenture_commit : completion (completion-only) - hires the youth as a trainee clerk,
;                      mints the {@self master <master>} bond, clears the goal.
; ----------------------------------------------------------------------------

(npc-think indenture_go
  (short-term-think)
  (goal {@self seek_indenture})
  ; articles-building BINDS ?venue (the master's premises) off the goal-focus
  ; articles, threading it to the at-place gate + the (go) effect.
  (when (and (articles-building (goal-focus seek_indenture) ?venue)
             (not (at-place ?venue))))
  (utility 80)
  (cont-fire-effects (excl-goal {@self go ?venue})))

(npc-think indenture_dwell
  (short-term-think)
  (goal {@self seek_indenture})
  (when (and (articles-building (goal-focus seek_indenture) ?venue)
             (at-place ?venue)))
  (utility 80)
  (effects (begin-act {@self seek_indenture} 90 indenture_commit)))

(npc-think indenture_commit
  (on-completion)
  ; bind the master's articles to a plain ?var (a macro arg used as a {pattern}
  ; subject inside hire-seq must be a ?var, not an expr). Needed in the gate, so
  ; it is a top-level (bind ...), evaluated before (when).
  (bind (goal-focus seek_indenture) ?art)
  ; org-founder BINDS ?master off the articles; the gate also drops the commit
  ; cleanly if the org's articles became unreadable (no master to bond to).
  (when (org-founder ?art ?master))
  (effects
    (hire-seq ?art [k job clerk] [k trainee])
    (begin-belief {@self master ?master})
    (end-goal {@self seek_indenture})
    ))
