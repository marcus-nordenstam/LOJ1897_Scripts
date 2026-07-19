; ----------------------------------------------------------------------------
; dimensions.hs - value-dimension DEFS (define-macro). A value dim is a 0..1
; magnitude a fusion or utility reads on demand - never a minted belief. It was
; a Shape V (value) classifier in definitions/signals.hs; here it is an ordinary
; zero-arg macro inlined by every consumer, so there is ONE encoding and no
; classifier catalog to evaluate it. Consumers write (dimname) in place of the
; retired (classifier-value dimname).
;
; The macro bodies are ordinary .hs read/fold expressions (attr / believes /
; count-beliefs / count-ever / evidence + the + - * / min max clamp >= <=
; combinators). (believes {@self L ?}) is the boolean "holds an ongoing L"
; (0-or-1 in arithmetic); (count-beliefs @self L) the ongoing tally;
; (count-ever @self L) the any-tense tally (ended act-records count); the
; per-attr default is 0 when absent (traits are always present on generated
; humans).
; ----------------------------------------------------------------------------

; criminality - a low base (0.05), raised 0.25 per recorded crime of ANY tense
; (assault / theft / fraud / embezzlement / homicide / kidnap - the act-records
; the crime pipeline writes). A single conviction reads middling; a habitual
; offender saturates.
(define-macro criminality ()
  (clamp (+ 0.05
            (* (+ (count-ever @self assault) (count-ever @self steal)
                  (count-ever @self defraud) (count-ever @self embezzle)
                  (count-ever @self kill)    (count-ever @self kidnap)) 0.25)) 0 1))

; rootedness - how established the NPC is in the community. Local lineage
; (mother / father), a spouse, children (each +0.06, capped at 4 = +0.24), a
; steady employer, owned property and club membership each add a partial score;
; the sum clamps to 1. A recently-arrived immigrant with just an employer reads
; low (~0.20); a settled local family reads high.
(define-macro rootedness ()
  (clamp (+ (* 0.15 (believes {@self mother ?}))
            (* 0.15 (believes {@self father ?}))
            (* 0.20 (believes {@self spouse ?}))
            (* 0.06 (min (count-beliefs @self child) 4))
            (* 0.20 (believes {@self employer ?}))
            (* 0.15 (>= (count-beliefs @self building) 1))
            (* 0.10 (>= (count-beliefs @self member_of) 1))) 0 1))

; piety - worship-episode observance mapped onto the historical piety anchors:
; 0.25 the never-worships floor, 0.85 the regular-churchgoer ceiling. observance
; is the recency-weighted mass of the subject's OWN worship memories (forgetting
; them honestly degrades it; the church-going pretender fools it by design).
(define-macro piety ()
  (clamp (+ 0.25 (* (evidence @self worship 6 6) 0.60)) 0 1))

; inhibition - the moral / conscientious brake on pressure-driven impulse. A
; weighted fold of politeness / industriousness / compassion / piety / decorum
; minus the disinhibition trait-fold (low industriousness + low politeness + high
; volatility, inlined - the top-level name is taken by score_macros' inverse-
; inhibition reading) / stress, with the above-population-mean dark-tetrad terms
; (the one-sided amplification convention) and the held-value / justification
; counts. decorum is a C++ float belief and stress a mood belief - both read
; absent-safe (0 when the subject holds none, e.g. children / fresh spawns).
(define-macro inhibition ()
  (clamp (+ (+ (* (attr @self politeness)      0.30)
               (* (attr @self industriousness) 0.30)
               (* (attr @self compassion)      0.15)
               (* (piety)                       0.20)
               (* (if (believes {@self decorum ?}) (target {@self decorum}) 0) 0.10)
               (* (/ (+ (- 1 (attr @self industriousness)) (- 1 (attr @self politeness))
                        (attr @self volatility)) 3) -0.20)
               (* (if (believes {@self stress ?})  (target {@self stress})  0) -0.30))
            (+ (* (clamp (+ (attr @self narcissism)       -0.5) 0 1) -0.10)
               (* (clamp (+ (attr @self machiavellianism) -0.5) 0 1) -0.15)
               (* (clamp (+ (attr @self psychopathy)      -0.5) 0 1) -0.20)
               (* (clamp (+ (attr @self sadism)           -0.5) 0 1) -0.25)
               (* (count-beliefs @self value)    0.05)
               (* (count-beliefs @self justify) -0.08))) 0 1))
