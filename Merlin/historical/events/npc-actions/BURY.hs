; ----------------------------------------------------------------------------
; bury (act lane) - the priest's burial rite act (bury_action). The planning thinks
; (bury_route / bury_onsite) live in npc-think/intra-day/bury_think.hs.
;
;   bury_action (act): perform the rites via the blessed rite ops - the verdict
;     ledger row, the tombstone (the dead mind's rendered memory timeline), and
;     (for a violent corpse) public murder-awareness - then destroy the corpse
;     and end the act. The corpse is a SINGLE known role-cast object destroyed
;     in the act (safe: no mark, no sweep, no in-flight role walk).
; ----------------------------------------------------------------------------

; The rite. Reads (verdict / tombstone / violence) BEFORE the destroy while the
; corpse still resolves, then realizes the interment: the priest's own ongoing
; {?corpse internment buried} (a separate @excl axis from `condition`, so `dead`
; stands beside it), TOLD to everyone co-present at the rite (the
; conveyer, the mourners), AND propagated to the deceased's whole social circle
; ((propagate-burial) - the funeral / parish register is public knowledge, the
; same channel the death itself travelled), so every knower's dead-and-not-
; buried bury / convey filters unmatch and the standing-corpse pools drain.
; Then the corpse is destroyed and the act-belief ended (so the act fires
; exactly once - the engine does not auto-end it). The act-label lives in the
; cached self-role gate: the promotion scan rejects O(1) before any mind-entry.
(npc-action {@self BURY ?corpse}
  (duration 60)
  (effects
    (record-verdict ?corpse)
    (tombstone ?corpse)
    (if (violent-corpse ?corpse) (then (propagate-murder-awareness ?corpse)))
    (realize-destroyed ?corpse internment [k internment buried])
    (tell (utterable-msg {?corpse internment [k buried]}))
    (propagate-burial ?corpse)
    (destroy-entity ?corpse)
    (set-outcome {@self BURY ?corpse} succ)))
; go_action (the shared travel act) lives in npc-actions/go_action.hs.
