; ----------------------------------------------------------------------------
; kidnap - NO-OP declaration stub. The abduction crime record ({@self kidnap
; ?victim}) is read by the criminality classifiers (dimensions.hs); this npc-task
; exists only to SELF-DECLARE the `kidnap` label + its crime metadata so the
; Tasks.mon row can retire. To be fleshed out into the real abduction task later.
; The (try) never fires (declaration only).
; ----------------------------------------------------------------------------

(npc-task {@self kidnap ?victim}:?kidnap-rel
  (tar human)
  (construed_act coercion_act threaten_act wrong_act) (theme coercive_to) (contradicts liberty)
  (facets reportable_crime) (obs)
  (try
    (role @self)
    (when (chance 0))
    (effects (set-outcome ?kidnap-rel /succ))))
