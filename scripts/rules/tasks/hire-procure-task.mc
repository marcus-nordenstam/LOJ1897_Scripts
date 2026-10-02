; ----------------------------------------------------------------------------
; hire-procure ?agent ?kind - the covert paid channel: get a known third party to
; obtain a ?kind for you, so neither the purchase nor the theft traces to you. FOR NOW
; this boils down to a SAY, like hire-assassin: reach the agent and solicit them; the
; agent taking up the procurement + delivering is deferred. The instigator re-tries if
; nothing arrives. Concludes once the solicitation has been spoken.
; ----------------------------------------------------------------------------


(task {@self hire-procure ?agent ?kind}:?hire-procure
  (tar [k human] @object)
  (aux ?)
  (and
    (try
      (when (or (spatial ?agent co-located @self) (spatial ?agent space)))
      (declare-utility errand always-pick)
      (effects (maintain-proposal {@self tell (utterable-msg {?agent acquire ?kind}) ?agent})))
    (try
      (when {@self tell ? ?agent /succ /caused_by ?hire-procure})
      (effects (set-outcome ?hire-procure /succ)))))
