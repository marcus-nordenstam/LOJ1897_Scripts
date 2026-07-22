; ----------------------------------------------------------------------------
; apprentice_errand (think lane) - the npc-THINK half of the apprenticeship split
; (Item 5). The go/dwell rungs that route the youth to the master's premises and
; promote the articling act (npc-act/apprentice_errand.hs).
;
;   indenture_go     : hold the aim, not at the premises -> travel sub-goal.
;   indenture_dwell  : hold the aim, AT the premises -> propose the articling (indenture_act).
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

; TERMINAL (act_body_purification): AT the premises, PROPOSE the articling act - it no longer
; promotes off the bare {@self seek_indenture} aim (a proposed label drops out of goal
; competition). articles-building binds ?venue (the master's premises) off the goal-focus and the
; (in-building ?venue) gate is the arrived condition; the (goal ...) gate supplies the /cause +
; drive. Reactive (schedule always): re-proposes each decision point while the aim stands + inside.
(npc-think indenture_dwell
  (schedule always)
  (goal {@self seek_indenture})
  (when (and (articles-building (goal-focus seek_indenture) ?venue)
             (in-building ?venue)))
  (utility 80)
  (effects (propose {@self seek_indenture})))
