; ----------------------------------------------------------------------------
; retire (npc-action) - the ACT half of the retirement split. The go/dwell think
; half lives in npc-think/retire.hs; this file holds the dwell completion that
; commits the retirement (fires the worker) AT the workplace.
; ----------------------------------------------------------------------------

(npc-action quit_work_act
  (act {@self quit_work})
  (duration 60)
  (act-effects
    (fire /worker @self)
    (end-act  {@self quit_work})))
