; ----------------------------------------------------------------------------
; hire-procure ?agent ?kind - the covert paid channel: get a known third party to
; obtain a ?kind for you, so neither the purchase nor the theft traces to you. FOR NOW
; this boils down to a SAY, like hire-assassin: reach the agent and solicit them; the
; agent taking up the procurement + delivering is deferred. The instigator re-tries if
; nothing arrives. Concludes once the solicitation has been spoken.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-task {@self hire-procure ?agent ?kind}:?hire-rel
  (tar human)
  (aux ?)
  (and
    (try
      (when (and (not (spatial ?agent co-located @self))
                 (spatial ?agent space): ?loc))
      (utility errand)
      (effects (maintain-proposal {@self go ?loc})))
    (try
      (when (spatial ?agent co-located @self))
      (utility errand always-pick)
      (effects (maintain-proposal {@self SAY (utterable-msg {?agent acquire ?kind}) ?agent})))
    (try
      (when (any {@self SAY ? /succ /caused_by ?hire-rel}))
      (effects (set-outcome ?hire-rel /succ)))))
