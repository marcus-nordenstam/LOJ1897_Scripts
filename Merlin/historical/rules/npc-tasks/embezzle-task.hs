; ----------------------------------------------------------------------------
; embezzle - NO-OP declaration stub. The workplace-theft crime record
; ({@self embezzle ?victim}) is currently minted by the burgle lane
; (burgle_strike, at the thief's own workplace); this npc-task exists only to
; SELF-DECLARE the `embezzle` label + its crime metadata so the Tasks.mon row
; can retire. To be fleshed out into the real embezzlement task later. The (try)
; never fires (the label is minted as a record, never promoted as a task).
; ----------------------------------------------------------------------------

(npc-task {@self embezzle ?victim}:?embezzle-rel
  (tar human|org)
  (construed_act appropriation_act wrong_act betray_act) (theme thief_to) (contradicts trust)
  (facets reportable_crime blackmailable)
  (try
    (role @self)
    (when (chance 0))
    (effects (set-outcome ?embezzle-rel succ))))
