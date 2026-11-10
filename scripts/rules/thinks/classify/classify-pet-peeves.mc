; ----------------------------------------------------------------------------
; classify-pet-peeves - the aversions a man's temperament gives him: the devout cannot abide drink,
; the courteous a slight given anyone (funcs/particulars.mc).
; ----------------------------------------------------------------------------

; How strong a trait must be to make its peeve.
(define-macro peeve-trait-min () 0.75)

(think classify-pet-peeves
  (and
    (try
      (belief {@self devoutness ?devoutness} -{@self aversion [k alcoholic-drink]}
        (when (>= ?devoutness (peeve-trait-min)))
        (effects (begin-belief {@self aversion [k alcoholic-drink]}))))
    (try
      (belief {@self politeness ?politeness} -{@self aversion [k slight-act]}
        (when (>= ?politeness (peeve-trait-min)))
        (effects (begin-belief {@self aversion [k slight-act]}))))))
