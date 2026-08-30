; ----------------------------------------------------------------------------
; summon - NO-OP declaration stub. The organiser's call to compete is currently
; recorded as a relation ({@self summon ?member ?sport}, minted by HOLD_MEET_RUN
; and cleared by RACE_RUN); this npc-task exists only to SELF-DECLARE the `summon`
; label + its field shape so the Tasks.mon row can retire. To be fleshed out into
; the real summon task later. The (try) never fires (declaration only).
; ----------------------------------------------------------------------------

(npc-task {@self summon ?member ?sport}:?summon-rel
  (tar human)
  (aux ?)
  (try
    (role @self)
    (when (chance 0))
    (effects (set-outcome ?summon-rel /succ))))
