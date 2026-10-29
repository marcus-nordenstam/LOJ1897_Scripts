; ----------------------------------------------------------------------------
; classify-confidant - a close friend of @self's who is neither kin nor his spouse is his
; confidant: told what he keeps from kin and spouse ((disclosure confidant)). He stops being one
; when he is no longer that close, or becomes kin or a spouse.
; ----------------------------------------------------------------------------

(think classify-confidant
  (and
    (try
      (role ?other {@self close-to ?other}
                   -{@self confidant ?other}
                   -{@self (kin-labels) ?other}
                   -{@self spouse ?other}
        (effects (begin-belief {@self confidant ?other}))))
    (try
      (role ?other {@self confidant ?other}:?confidant
        (when (or (none {@self close-to ?other})
                  (substantial (any {@self (kin-labels) ?other}))
                  (substantial (any {@self spouse ?other}))))
        (effects (end-belief ?confidant))))))
