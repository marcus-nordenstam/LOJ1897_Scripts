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

; AT the premises: a MAINTENANCE minter for the standing seek_indenture aim. begin-goal
; registers this think's utility source so the aim (its go sub-goal spent, now the leaf) wins
; the motor and promotes to indenture_act; the cease-effects end the aim when @self leaves the
; premises (the (in-building ?venue) gate drops).
(npc-think indenture_dwell
  (schedule on-commit)
  (goal {@self seek_indenture})
  (when (and (articles-building (goal-focus seek_indenture) ?venue)
             (in-building ?venue)))
  (utility 80)
  (effects       (begin-goal {@self seek_indenture}))
  (cease-effects (end-goal   {@self seek_indenture})))
