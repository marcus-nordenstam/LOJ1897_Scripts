; ----------------------------------------------------------------------------
; apprentice_errand (think lane) - the npc-THINK half of the apprenticeship split
; (Item 5). The go/dwell rungs that route the youth to the master's premises and
; promote the articling act (npc-act/apprentice_errand.hs).
;
;   indenture_go     : hold the aim, not at the premises -> travel sub-goal.
;   indenture_dwell  : hold the aim, AT the premises -> propose the articling (indenture_act).
; ----------------------------------------------------------------------------

(npc-think indenture_go
  (goal {@self SEEK_INDENTURE ?art})
  ; articles-building BINDS ?venue (the master's premises) off the ?art focus bound
  ; off the {@self SEEK_INDENTURE} goal, threading it to the at-place gate + the (go)
  ; effect. The trainee gate quenches the lane once indentured (live job-level read):
  ; the SEEK_INDENTURE goal lingers until the minter's monthly falling edge, so
  ; without it a freshly-hired trainee would keep walking back to re-present at the door.
  (when (and (articles-building ?art ?venue)
             (not (spatial @self building ?venue))
             (!= (job-level @self) [k trainee])))
  (effects (maintain-proposal {@self enter ?venue})))

; TERMINAL (act_body_purification): AT the premises, PROPOSE the articling act (a proposed label
; drops out of goal competition, so it does not auto-promote off the bare {@self SEEK_INDENTURE}
; aim). articles-building binds ?venue (the master's premises) off the ?art focus bound off the {@self SEEK_INDENTURE} goal and the
; (spatial @self building ?venue) gate is the arrived condition; the (goal ...) gate supplies the /caused_by +
; drive.
(npc-think indenture_dwell
  (goal {@self SEEK_INDENTURE ?art})
  ; The trainee gate blocks re-proposing (and so re-running) indenture_act during the
  ; gap between the hire and the minter's monthly falling-edge cease of the aim: once
  ; hire-seq sets the youth's live job-level to trainee, this stops proposing.
  (when (and (articles-building ?art ?venue)
             (spatial @self building ?venue)
             (!= (job-level @self) [k trainee])))
  (effects (maintain-proposal {@self SEEK_INDENTURE})))
