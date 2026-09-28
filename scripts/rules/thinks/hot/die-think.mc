; ----------------------------------------------------------------------------
; die-now - the act a death decision stands for. Whatever decided he dies (age, disease,
; his own despair) minted {@self goal {@self DIE ?cause}}; this keeps DIE proposed until
; it is done, which ends him.
; ----------------------------------------------------------------------------

(think die-now
  (goal {@self DIE ?cause})
  (effects (maintain-proposal {@self DIE ?cause})))
