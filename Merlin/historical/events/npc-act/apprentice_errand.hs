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
;   indenture_go     : hold the aim, not at the premises -> travel sub-goal.
;   indenture_dwell  : hold the aim, AT the premises -> feed the aim this think's drive
;                      so it PROMOTES (the go sub-goal done, the aim is the leaf).
;   indenture_act    : the promoted act - the 90-min articling; matched by its (when)
;                      on the promoted {@self seek_indenture} belief. Hires the youth,
;                      mints the master bond, ends the act + the aim.
; ----------------------------------------------------------------------------

(npc-think indenture_go
  (short-term-think)
  (goal {@self seek_indenture})
  ; articles-building BINDS ?venue (the master's premises) off the goal-focus
  ; articles, threading it to the at-place gate + the (go) effect.
  (when (and (articles-building (goal-focus seek_indenture) ?venue)
             (not (in-building ?venue))))
  (utility 80)
  (cont-fire-effects (go-into ?venue)))

; AT the premises: re-affirm the standing seek_indenture aim with this think's utility so
; it carries a drive. With the go sub-goal spent, the aim is the leaf and promotes to
; indenture_act. begin-goal (not excl-goal) - the aim is a latched goal, not this node's
; to auto-retract; the utility source is what makes it win the motor here.
(npc-think indenture_dwell
  (short-term-think)
  (goal {@self seek_indenture})
  (when (and (articles-building (goal-focus seek_indenture) ?venue)
             (in-building ?venue)))
  (utility 80)
  (cont-fire-effects (begin-goal {@self seek_indenture})))

; The 90-min articling. Promoted from the seek_indenture aim at the premises; its (when)
; matches the promoted {@self seek_indenture} belief + binds the master off the articles
; (dropping cleanly if unreadable). Ends both the running act and the aim on completion.
(npc-act indenture_act
  ; bind the master's articles to a plain ?var (a macro arg used as a {pattern}
  ; subject inside hire-seq must be a ?var, not an expr).
  (bind (goal-focus seek_indenture) ?art)
  (when (and (believes {@self seek_indenture})
             (org-founder ?art ?master)))
  (duration 90)
  (act-effects
    (hire-seq ?art [k job clerk] [k trainee])
    (begin-belief {@self master ?master})
    (end-act {@self seek_indenture})
    (end-goal {@self seek_indenture})))
