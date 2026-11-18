; ----------------------------------------------------------------------------
; introduce ?a ?b - @self makes two people with her known to each other: one introduction said to
; both at once, no turn taken - "Ann, this is your sister Mary, and Mary, this is your brother .." -
; the bonds told inside it, each pointed out as it is heard ((this ..)), so each holds the one he
; sees. Brothers and sisters for now, the bond each stands in to the other named as @self knows them
; (kin-label). It succeeds when the line is said.
; ----------------------------------------------------------------------------

(task {@self introduce ?a ?b}:?introduce
  (belief-timeout 15 min)
  (tar [k human] @object)
  (aux [k human] @object)
  (preemptive-or
    (try
      (belief {@self SAY ? /succ /caused_by ?introduce}
        (effects (set-outcome ?introduce /succ))))
    (try
      (when (spatial ?a co-located @self) (spatial ?b co-located @self))
      (bind (kin-label sibling ?a) ?bond-to-a)
      (bind (kin-label sibling ?b) ?bond-to-b)
      (effects
        (maintain-intent {@self intent {@self SAY (formulaic [] introduction
                                          (msg /utterable [] {(this ?b) ?bond-to-a (this ?a)} {(this ?a) ?bond-to-b (this ?b)}))}})))))
