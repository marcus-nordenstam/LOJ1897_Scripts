; go-between (the underworld fixer) - NOT-reputable (neither exemplary nor
; respectable) + lower/middle class + the externalizing temperament to broker
; violence (the corrupt publican / fence / flash sporting-man). NB "disinhibition"
; here is the externalizing trait fold (low industriousness + low politeness +
; high volatility), NOT the (disinhibition) = 1 - inhibition macro.
;
; TODO - this is SELF-knowledge only, and nothing reads it yet.
; The old C++ hireling census walked every mind to build a global "fixer pool";
; that was a director read and is purged. A fixer is worth nothing until another
; mind can come to believe {?other prototype go-between} on its own evidence, so
; the work is:
;   (a) a per-observer twin, classify_others_go_between, on the
;       classify-others-repute template in classify-others-repute.mc - (role ?other ..) +
;       (mint-band-about {?other prototype} ..) folding only what @self has
;       personally witnessed or been told about ?other;
;   (b) an "ask the fixer" rung in hire-assassin-task.mc, since the whole POINT of
;       a go-between is that you need not know a killer yourself - you need to know
;       someone who does. That rung is how an employer ACQUIRES the name.
(think classify-go-between
  (rng-stream behaviour)
  (role @self {@self industriousness ?industriousness}
              {@self politeness ?politeness}
              {@self volatility ?volatility}
              {@self repute ?, class-situation ?}
    (effects
      (mint-band {@self prototype}
        (* (* (- 1.0 (prob {@self repute [k repute exemplary]}))
              (- 1.0 (prob {@self repute [k repute respectable]})))
           (clamp (+ (prob {@self class-situation [k class-situation lower]})
                     (prob {@self class-situation [k class-situation middle]})) 0.0 1.0)
           (>= (/ (+ (- 1.0 ?industriousness)
                     (- 1.0 ?politeness)
                     ?volatility) 3.0)
               0.50))
        [k prototype go-between] 0.5))))
