; ----------------------------------------------------------------------------
; apprentice_errand (think lane) - the npc-THINK half of the apprenticeship split
; (Item 5). The go/dwell rungs that route the youth to the master's premises and
; promote the articling act (npc-act/apprentice_errand.hs).
;
;   indenture_go     : hold the aim, not at the premises -> travel sub-goal.
;   indenture_dwell  : hold the aim, AT the premises -> propose the articling (indenture_act).
; ----------------------------------------------------------------------------

(npc-think indenture_go
  (goal {@self seek_indenture ?art})
  ; articles-building BINDS ?venue (the master's premises) off the ?art focus bound
  ; off the {@self seek_indenture} goal, threading it to the at-place gate + the (go)
  ; effect. The trainee gate quenches the lane once indentured (live job-level read):
  ; the seek_indenture goal lingers until the minter's monthly falling edge, so
  ; without it a freshly-hired trainee would keep walking back to re-present at the door.
  (when (and (articles-building ?art ?venue)
             (not (in-building ?venue))
             (not (= (job-level @self) [k trainee]))))
  (utility 80)
  (effects (maintain-proposal {@self enter ?venue})))

; TERMINAL (act_body_purification): AT the premises, PROPOSE the articling act (a proposed label
; drops out of goal competition, so it does not auto-promote off the bare {@self seek_indenture}
; aim). articles-building binds ?venue (the master's premises) off the ?art focus bound off the {@self seek_indenture} goal and the
; (in-building ?venue) gate is the arrived condition; the (goal ...) gate supplies the /cause +
; drive.
(npc-think indenture_dwell
  (goal {@self seek_indenture ?art})
  ; The trainee gate blocks re-proposing (and so re-running) indenture_act during the
  ; gap between the hire and the minter's monthly falling-edge cease of the aim: once
  ; hire-seq sets the youth's live job-level to trainee, this stops proposing.
  (when (and (articles-building ?art ?venue)
             (in-building ?venue)
             (not (= (job-level @self) [k trainee]))))
  (utility 80)
  (effects (maintain-proposal {@self seek_indenture})))
