; ----------------------------------------------------------------------------
; flirt-suggests-fancy (reflex) - a flirt seen tells whoever saw it - the one flirted with or an
; onlooker - that the flirter likely fancies her. The seen flirt is the cause of the belief.
; ----------------------------------------------------------------------------

(reflex {?flirter flirt ?flirtee /ever}:?flirt
  (when (neq ?flirter @self))
  (effects (begin-belief {?flirter fancy ?flirtee /likely /caused_by ?flirt})))
