; ----------------------------------------------------------------------------
; bury (act lane) - the priest's burial rite act. The planning thinks (bury_route /
; bury_onsite) live in npc-think/intra-day/bury_think.hs.
;
;   bury_action (act): perform the rites via the blessed rite ops - the verdict
;     ledger row and the tombstone (the dead mind's rendered memory timeline) -
;     realize the interment, tell it to everyone co-present at the rite, then destroy
;     the corpse and end the act. The corpse is a SINGLE known role-cast object
;     destroyed in the act (safe: no mark, no sweep, no in-flight role walk).
;
; Death / burial KNOWLEDGE is PULLED, never pushed. Co-present mourners learn the death
; by SEEING the corpse and the interment by the (tell) at the rite; an absent mind learns
; only through a real channel of its own (perceiving the corpse, or reading a death
; notice). The rite writes into NO other mind.
; ----------------------------------------------------------------------------

(npc-action {@self BURY ?corpse}
  (duration 60)
  (effects
    (record-verdict ?corpse)
    (tombstone ?corpse)
    (realize-destroyed ?corpse internment [k internment buried])
    (tell (utterable-msg {?corpse internment [k buried]}))
    (destroy-entity ?corpse)
    (set-outcome {@self BURY ?corpse} /succ)))
; go_action (the shared travel act) lives in npc-actions/go_action.hs.
