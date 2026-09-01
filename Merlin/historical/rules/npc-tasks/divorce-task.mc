; ----------------------------------------------------------------------------
; divorce - getting a divorce: the betrayed husband's remedy (the period gives a wife
; no such recourse). Proposed by affair_fallout when a proper / high-decorum husband
; puts an unfaithful wife away. Performing it repudiates her: both spouse bonds end,
; her memory of being put away is minted (the mutual record), and a put-away wife is
; marked a fallen-woman in her mind AND his (the gossip channel carries the disgrace;
; betrothal / love_match exclude her), cast out of the marital roof, and turned out of
; any reputation-based post.
;
; The ended {@self divorce ?partner} task-belief IS @self's own record of having done
; it - the memory of being involved is the record, no fiat act-mint of his own.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")

(npc-task {@self divorce ?partner}:?divorce-rel
  (tar human)
  (try
    (role @self)
    (effects
      (end-belief {@self spouse ?partner})
      ; Mutual: end her reciprocal bond and land HER record of being put away.
      (end-belief ?partner {?partner spouse @self})
      (begin-belief {@self divorce ?partner /momentary})
      ; The fallen woman: marked in her mind AND his, expelled from the marital roof,
      ; dismissed from reputable service.
      (if {?partner gender [k female]}
          (then
            (begin-belief ?partner {?partner prototype [k fallen-woman]})
            (begin-belief {?partner prototype [k fallen-woman]})
            ; He puts her out: his OWN tenancy belief for her ends. What she now
            ; believes about where she lives is hers to reconcile.
            (for-each ?edw-h (every {@self home ?})
              (bind ?edw-h.target ?edw-home)
              (end-belief {?edw-home tenant ?partner}))
            ; Her dismissal from reputable service is her EMPLOYER's decision, not
            ; the husband's - it wants a rule on the employer reading her new
            ; standing. Commented out pending that.
            ))
      (set-outcome ?divorce-rel /succ))))
