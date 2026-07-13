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
; corpse still resolves, then realizes the interment: the priest's own ongoing
; {?corpse condition buried} (realize-destroyed keeps the `dead` condition beside
; it - condition is non-exclusive), TOLD to everyone co-present at the rite (the
; conveyer, the mourners) through the ordinary communication channel, so their
; dead-and-not-buried bury / convey filters unmatch too. Absent knowers keep
; their stale dead-belief until it fades on the normal decay curve (a corpse is
; a peripheral object) - honest ignorance, not a propagation target. Then the
; corpse is destroyed and the act-belief ended (so the act fires exactly once -
; the engine does not auto-end it).
(npc-act bury_act
  (when (believes {@self bury ?corpse}))
  (duration 60)
  (act-effects
    (record-verdict ?corpse)
    (tombstone ?corpse)
    (if (violent-corpse ?corpse) (propagate-murder-awareness ?corpse))
    (realize-destroyed ?corpse [k condition buried])
    (tell {?corpse condition [k buried]})
    (destroy-entity ?corpse)
    (end-act {@self bury ?corpse})))
; go_act (the shared travel act) lives in npc-act/go.hs.
