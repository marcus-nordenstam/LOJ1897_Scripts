; ----------------------------------------------------------------------------
; defraud - NO-OP declaration stub. The fraud crime record ({@self defraud
; ?victim}) is read by the criminality classifiers (dimensions.hs) and the
; life-aim affinities; this npc-task exists only to SELF-DECLARE the `defraud`
; label + its crime metadata so the Tasks.mon row can retire. To be fleshed out
; into the real fraud task later. The (try) never fires (declaration only).
; ----------------------------------------------------------------------------

(npc-task {@self defraud ?victim}:?defraud-rel
  (track-skill-level [k forgery])
  (tar human)
  (construed_act appropriation_act wrong_act betray_act) (theme thief_to) (contradicts property)
  (facets reportable_crime blackmailable)
  (try
    (role @self)
    (when (chance 0))
    (effects (set-outcome ?defraud-rel /succ))))
