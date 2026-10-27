; ----------------------------------------------------------------------------
; classify-unease - a man talking with someone he is not close to is ill at ease in that
; conversation: it forms when he takes part in it with such a one, and it goes when he no longer
; takes part. The motive of smalltalk (drivers/smalltalk-driver.mc).
; ----------------------------------------------------------------------------

(think classify-unease
  (and
    (try
      (role ?talk {?talk participant @self} -{@self unease ?talk}
        (role ?other {?talk participant ?other}
                     -{@self (closeness-labels friend) ?other}
                     (neq ?other @self)
          (effects (begin-belief {@self unease ?talk})))))
    (try
      (role ?talk {@self unease ?talk} -{?talk participant @self}
        (effects (end-belief {@self unease ?talk}))))))
