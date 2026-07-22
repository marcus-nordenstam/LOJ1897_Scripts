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
  ; articles, threading it to the at-place gate + the (go) effect. The trainee gate
  ; quenches the lane once indentured (live job-level read): the seek_indenture goal
  ; lingers until the minter's monthly falling edge, so without it a freshly-hired
  ; trainee would keep walking back to re-present at the door.
  (when (and (articles-building (goal-focus seek_indenture) ?venue)
             (not (in-building ?venue))
             (not (= (job-level @self) [k trainee]))))
  (utility 80)
  (effects       (begin-goal {@self enter ?venue}))
  (cease-effects (end-goal   {@self enter ?venue})))

; TERMINAL (act_body_purification): AT the premises, PROPOSE the articling act - it no longer
; promotes off the bare {@self seek_indenture} aim (a proposed label drops out of goal
; competition). articles-building binds ?venue (the master's premises) off the goal-focus and the
; (in-building ?venue) gate is the arrived condition; the (goal ...) gate supplies the /cause +
; drive. Reactive (schedule always): re-proposes each decision point while the aim stands + inside.
(npc-think indenture_dwell
  (schedule on-commit)
  (if-blocked hold)
  (goal {@self seek_indenture})
  ; The trainee gate blocks re-proposing (and so re-running) indenture_act during the
  ; gap between the hire and the minter's monthly falling-edge cease of the aim: once
  ; hire-seq sets the youth's live job-level to trainee, this stops proposing.
  (when (and (articles-building (goal-focus seek_indenture) ?venue)
             (in-building ?venue)
             (not (= (job-level @self) [k trainee]))))
  (utility 80)
  (effects (maintain-proposal {@self seek_indenture})))
