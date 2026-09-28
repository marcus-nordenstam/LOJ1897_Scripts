; ----------------------------------------------------------------------------
; kidnap - NO-OP declaration stub. The abduction crime record ({@self kidnap
; ?victim}) is read by the criminality classifiers (dimensions.mc); this task
; exists only to SELF-DECLARE the `kidnap` label + its crime metadata so the
; tasks.mon row can retire. To be fleshed out into the real abduction task later.
; The (try) never fires (declaration only).
; ----------------------------------------------------------------------------

(task {@self kidnap ?victim}:?kidnap
  (track-skill-level [k illicit])
  (tar [k human] @object)
  (construed-act coercion-act threaten-act wrong-act) (theme coercive-to) (contradicts liberty)
  (facets reportable_crime) (obs)
  (try
    (role @self
      (when (chance 0))
      (effects (set-outcome ?kidnap /succ)))))
