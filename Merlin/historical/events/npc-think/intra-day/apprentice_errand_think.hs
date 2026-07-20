; ----------------------------------------------------------------------------
; apprentice_errand (think lane) - the npc-THINK half of the apprenticeship split
; (Item 5). The go/dwell rungs that route the youth to the master's premises and
; promote the articling act (npc-act/apprentice_errand.hs).
;
;   indenture_go     : hold the aim, not at the premises -> travel sub-goal.
;   indenture_dwell  : hold the aim, AT the premises -> feed the aim this think's drive
;                      so it PROMOTES (the go sub-goal done, the aim is the leaf).
; ----------------------------------------------------------------------------

(npc-think indenture_go
  (schedule on-commit)
  (if-blocked hold)
  (goal {@self seek_indenture})
  ; articles-building BINDS ?venue (the master's premises) off the goal-focus
  ; articles, threading it to the at-place gate + the (go) effect.
  (when (and (articles-building (goal-focus seek_indenture) ?venue)
             (not (in-building ?venue))))
  (utility 80)
  (effects       (begin-goal {@self enter ?venue}))
  (cease-effects (end-goal   {@self enter ?venue})))

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
