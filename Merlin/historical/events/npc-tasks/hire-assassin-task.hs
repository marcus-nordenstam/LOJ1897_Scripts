; ----------------------------------------------------------------------------
; hire-assassin (npc-task) - a killing method proposed by choose_kill_method off a
; standing kill goal, chosen when @self can afford it (bank_balance gate). FOR NOW it
; boils down to a SAY: reach a known third party and solicit them to kill the victim.
; The hired killer choosing their own method + actually carrying it out is deferred
; (the old commission_killing conspiracy seam) - so today this is the solicitation act,
; and the instigator re-deliberates (choose_kill_method re-rolls) if no death follows.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-task {@self hire-assassin ?victim}:?hire
  (tar human)
  (role ?killer (any_human ?killer)
                (personally-knows @self ?killer)
                (not (= ?killer ?victim)))
  (and
    ; REACH the prospective killer.
    (try
      (when (and (not (co-present ?killer @self))
                 (location ?killer): ?loc))
      (utility survival)
      (effects (maintain-proposal {@self go ?loc})))

    ; SOLICIT: co-present, put the contract to them (a SAY - the words are the deed).
    (try
      (when (co-present ?killer @self))
      (utility survival always-pick)
      (effects (maintain-proposal {@self SAY (utterable-msg (to ?killer) {?killer kill ?victim}) ?killer})))

    ; CONCLUDE once the solicitation has been spoken.
    (try
      (when (any {@self SAY ? /succ /caused_by ?hire}))
      (effects (set-outcome ?hire succ)))))
