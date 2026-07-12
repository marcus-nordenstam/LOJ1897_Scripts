; ----------------------------------------------------------------------------
; retire (npc-act) - the ACT half of the retirement split. The go/dwell think
; half lives in npc-think/retire.hs; this file holds the dwell completion that
; commits the retirement (fires the worker) AT the workplace.
; ----------------------------------------------------------------------------

(npc-act quit_work_act
  (when (believes {@self quit_work}))
  (duration 60)
  (act-effects
    (fire /worker @self)
    (end-act {@self quit_work})
    (end-goal {@self quit_work})))
