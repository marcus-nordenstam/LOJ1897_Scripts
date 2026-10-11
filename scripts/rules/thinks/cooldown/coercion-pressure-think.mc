; ----------------------------------------------------------------------------
; coercion-pressure - the threatened man's own dread. While he holds a threat told him
; ({?coercer threaten @self (consequence ..)}), he feels exposure-risk pressure toward the
; coercer, caused by the threat, its weight scaled by his class's stake; when the threat ends
; the pressure loses its cause and fades.
; ----------------------------------------------------------------------------

(think coercion-pressure
  (role @self {@self class-situation ?class}
    (role ?coercer {?coercer isa [k human], condition [k alive]}
                   {?coercer threaten @self ?}:?threat
      (effects
        (mint-pressure-caused [k exposure-risk] ?coercer
                              (* 1440.0
                                 (switch (kind ?class)
                                   (on [k upper]  1.5)
                                   (on [k middle] 1.2)
                                   (else 1.0)))
                              ?threat)))))
