; ----------------------------------------------------------------------------
; defraud - NO-OP declaration stub. The fraud crime record ({@self defraud
; ?victim}) is read by the criminality classifiers (dimensions.mc) and the
; life-aim affinities; this task exists only to SELF-DECLARE the `defraud`
; label + its crime metadata so the tasks.mon row can retire. To be fleshed out
; into the real fraud task later. The (try) never fires (declaration only).
; ----------------------------------------------------------------------------

(task {@self defraud ?victim}:?defraud
  (track-skill-level [k forgery])
  (tar [k human] @object)
  (construed-act appropriation-act wrong-act betray-act) (theme thief-to) (contradicts property)
  (facets reportable_crime blackmailable)
  (try
    (role @self
      (when (chance 0))
      (effects (set-outcome ?defraud /succ)))))
