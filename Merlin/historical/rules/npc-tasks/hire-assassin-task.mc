; ----------------------------------------------------------------------------
; hire-assassin (npc-task) - a killing method the kill task proposes (argmax over
; kill_method_table), chosen when @self can afford it (coin-balance gate). FOR NOW it
; boils down to a SAY: reach a known third party and solicit them to kill the victim.
; The hired killer choosing their own method + actually carrying it out is deferred
; (the old commission_killing conspiracy seam) - so today this is the solicitation act,
; and the kill task re-picks a method if no death follows.
;
; TODO - @self solicits ANYONE it personally knows, with no belief about whether
; they would ever take the work. The knowledge half is missing on both sides:
;   (a) PREFER a believed hireling. Once classify_others_for_hire exists (see the
;       TODOs in classifiers/prototypes.mc) the ?killer cast should score
;       {?killer prototype for-hire} above a bare acquaintance, so the solicitation
;       goes to someone @self has reason to think will accept.
;   (b) ACQUIRE the belief when @self holds none - a (try) rung ABOVE the reach /
;       solicit rungs. Two legal channels, both already modelled: approach a known
;       {?fixer prototype go-between} and ask for a name, or treat the solicitation
;       itself as the probe (you ask, and the answer teaches you). Either way the
;       task that needs the knowledge is the task that goes and gets it.
; Until then this lane works, but blindly - it asks whoever it happens to know.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")

(npc-task {@self hire-assassin ?victim}:?hire-rel
  (tar human)
  (role ?killer (any_human ?killer)
                (personally-knows @self ?killer)
                (!= ?killer ?victim))
  (and
    ; REACH the prospective killer.
    (try
      (when (and (not (spatial ?killer co-located @self))
                 (spatial ?killer space): ?loc))
      (utility survival)
      (effects (maintain-proposal {@self go ?loc})))

    ; SOLICIT: co-present, put the contract to them (a SAY - the words are the deed).
    (try
      (when (spatial ?killer co-located @self))
      (utility survival always-pick)
      (effects (maintain-proposal {@self SAY (utterable-msg {?killer kill ?victim}) ?killer})))

    ; CONCLUDE once the solicitation has been spoken.
    (try
      (when {@self SAY ? /succ /caused_by ?hire-rel})
      (effects (set-outcome ?hire-rel /succ)))))
