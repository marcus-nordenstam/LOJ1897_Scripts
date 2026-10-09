; ----------------------------------------------------------------------------
; wealth (classifier). Derives the 0..1 {@self wealth} dimension from the coins a man
; feels in his carrying cash and the estate his home stands for, each time the count he
; feels changes. classify-economic-situation bands it.
; ----------------------------------------------------------------------------

(include "../../../macros/money-macros.mc")

(think classify-wealth
  (role @self {@self age ?age}
    (role ?cash {@self carrying-cash ?cash} {?cash count ?coins}
      (when (>= ?age (wealth_age_min)))
      (effects
        (any {@self home ?home=@nothing})
        (begin-belief {@self wealth (/ (clamp (+ /float (/ /float ?coins (wealth_coin_div))
                                                       (if (substantial ?home)
                                                           (then (switch (kind ?home)
                                                                   (on [k manor]                40)
                                                                   (on [k townhouse]            30)
                                                                   (on [k farmhouse]            18)
                                                                   (on [k residential-building]  0)
                                                                   (else                        25)))
                                                           (else 0)))
                                              0.0 100.0)
                                       100.0)})))))
