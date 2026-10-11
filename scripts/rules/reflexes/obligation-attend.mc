; ----------------------------------------------------------------------------
; obligation-attend - an invitation obliges @self to attend the occasion, owed to the host who
; invited him; organizing an occasion obliges its host to attend it. Attending discharges it.
; ----------------------------------------------------------------------------

(reflex {?host invite @self ?occ}:?invite
  (when (none {@self obligation {@self attend ?occ} ?}))
  (effects (begin-belief {@self obligation {@self attend ?occ} ?host /caused_by ?invite})))

(reflex {@self organize ?occ}:?organize
  (when (none {@self obligation {@self attend ?occ} ?}))
  (effects (begin-belief {@self obligation {@self attend ?occ} @nothing /caused_by ?organize})))

(reflex {@self attend ?occ /succ}
  (effects
    (any {@self obligation {@self attend ?occ} ?}): ?obligation
    (if (substantial ?obligation)
        (then (end-belief ?obligation)))))
