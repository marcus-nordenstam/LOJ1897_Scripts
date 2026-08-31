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
      (begin-ended-belief ?partner {@self divorce ?partner})
      ; The fallen woman: marked in her mind AND his, expelled from the marital roof,
      ; dismissed from reputable service.
      (if {?partner gender [k female]}
          (then
            (begin-belief ?partner {?partner prototype [k fallen-woman]})
            (begin-belief {?partner prototype [k fallen-woman]})
            (expel-divorced-wife ?partner)
            (dismiss-from-service ?partner)))
      (set-outcome ?divorce-rel /succ))))
