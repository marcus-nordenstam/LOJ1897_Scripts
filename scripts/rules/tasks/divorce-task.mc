; ----------------------------------------------------------------------------
; divorce - getting a divorce: the betrayed husband's remedy (the period gives a wife
; no such recourse). Proposed by affair-fallout when a proper / high-decorum husband
; puts an unfaithful wife away. He tells her to her face that he is no longer her
; husband - a state, so she adopts it as told - and only then repudiates her in his own
; mind: his spouse bond ends, she is a fallen woman to him (the gossip channel carries
; the disgrace; betrothal / love-match exclude her), and his tenancy belief for her ends.
; Her half is hers: thinks/put-away-think.mc, on the told repudiation.
;
; Telling comes first because the proposer is cast on his spouse bond: ending it first
; would withdraw the task before she was told.
;
; The ended {@self divorce ?partner} task-belief IS @self's own record of having done it.
; ----------------------------------------------------------------------------


(task {@self divorce ?partner}:?divorce
  (facets gossip_worthy) (tell-rank 8)
  (tar [k human] @object)
  (init
    (expect {?partner gender [k female]} "divorce: only a husband puts a wife away"))
  (sequence
    (stage
      (when (spatial ?partner co-located @self))
      (effects
        (if -{@self tell ? ?partner /succ /caused_by ?divorce}
            (then (maintain-proposal {@self tell (msg /utterable [] {@self /not spouse ?partner}) ?partner})))))
    (stage
      (effects
        (end-belief {@self spouse ?partner})
        (begin-belief {?partner prototype [k fallen-woman]})
        (for-each ?edw-h (every {@self home ?})
          (bind ?edw-h.target ?edw-home)
          (end-belief {?edw-home tenant ?partner}))
        (set-outcome ?divorce /succ)))))
