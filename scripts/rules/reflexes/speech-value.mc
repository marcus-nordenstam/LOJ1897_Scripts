; ----------------------------------------------------------------------------
; speech-value (reflexes) - what a belief is worth saying, read once when it is minted: one of
; @self's own worth telling as news (worthy .. news-worthy) is news, one about a third party
; worth passing on (worthy .. gossip-worthy) is gossip. The drivers that tell them read these
; states, and each ends with the belief it is worth telling: what no longer holds is no news.
; ----------------------------------------------------------------------------

(reflex {@self (facet-labels news-worthy) ? /ever}:?told
  (when (and (dirty-born) (worthy ?told news-worthy)))
  (effects (begin-belief {@self news ?told})))

(reflex {?other (facet-labels gossip-worthy) ? /ever}:?heard
  (when (and (dirty-born) (neq ?other @self) (worthy ?heard gossip-worthy)))
  (effects (begin-belief {@self gossip ?heard})))

(reflex {@self (facet-labels news-worthy) ? /ever}:?told
  (when (and (dirty-ended) (substantial (any {@self news ?told}))))
  (effects (end-belief {@self news ?told})))

(reflex {?other (facet-labels gossip-worthy) ? /ever}:?heard
  (when (and (dirty-ended) (neq ?other @self) (substantial (any {@self gossip ?heard}))))
  (effects (end-belief {@self gossip ?heard})))
