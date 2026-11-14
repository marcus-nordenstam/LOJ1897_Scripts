; ----------------------------------------------------------------------------
; wealth (classifier). Derives the 0..1 {@self wealth} dimension from the estate his home stands
; for, once he is of an age to be reckoned and whenever his home changes; a man with no home has
; none. Never the coins in his pocket: wealth is what a man has, and changes rarely.
; classify-economic-situation bands it.
; ----------------------------------------------------------------------------

(include "../../../macros/money-macros.mc")

(think classify-wealth
  (belief {@self age ?age}
    (when (>= ?age (wealth_age_min)))
    (and
      (try
        (role ?home {@self home ?home}
          (effects
            (begin-belief {@self wealth (/ /float (switch (kind ?home)
                                                    (on [k manor]                40)
                                                    (on [k townhouse]            30)
                                                    (on [k farmhouse]            18)
                                                    (on [k residential-building]  0)
                                                    (else                        25))
                                                  100.0)}))))
      (try
        (belief -{@self home ?}
          (effects (begin-belief {@self wealth 0.0})))))))
