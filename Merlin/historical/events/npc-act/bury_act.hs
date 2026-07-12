; ----------------------------------------------------------------------------
; bury (act lane) - the priest's burial rite act (bury_act). The planning think
; (plan_burial) lives in npc-think/bury.hs.
;
;   bury_act (act): perform the rites via the blessed rite ops - the verdict
;     ledger row, the tombstone (the dead mind's rendered memory timeline), and
;     (for a violent corpse) public murder-awareness - then destroy the corpse
;     and end the act. The corpse is a SINGLE known role-cast object destroyed
;     in the act (safe: no mark, no sweep, no in-flight role walk).
; ----------------------------------------------------------------------------

; The rite. Reads (verdict / tombstone / violence) BEFORE the destroy while the
; corpse still resolves, then destroys the single known corpse and ends the
; act-belief (so the act fires exactly once - the engine does not auto-end it).
(npc-act bury_act
  (when (believes {@self bury ?corpse}))
  (duration 60)
  (act-effects
    (record-verdict ?corpse)
    (tombstone ?corpse)
    (if (violent-corpse ?corpse) (propagate-murder-awareness ?corpse))
    (destroy-entity ?corpse)
    (end-act {@self bury ?corpse})))
; go_act (the shared travel act) lives in npc-act/go.hs.
