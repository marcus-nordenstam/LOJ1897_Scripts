; ----------------------------------------------------------------------------
; set-mealtimes ?household - say the household's meal hours aloud at home, so the household
; hears and adopts them, then hold them herself. Proposed by the set-mealtimes driver
; (drivers/household-driver.mc).
; ----------------------------------------------------------------------------

(include "../../macros/home-macros.mc")

(task {@self set-mealtimes ?household}:?set-mealtimes
  (tar [k household] @object)
  (role ?home {@self home ?home}
    (and
      (try
        (belief -{@self tell ? _ /succ /caused_by ?set-mealtimes}
          (effects
            (bind (clock (household-breakfast-hour) 0) ?breakfast)
            (bind (clock (household-lunch-hour) 0) ?lunch)
            (bind (clock (household-supper-hour) 0) ?supper)
            (maintain-proposal {@self tell (msg /utterable [] {?home breakfast-hour ?breakfast}
                                                          {?home lunch-hour ?lunch}
                                                          {?home supper-hour ?supper}) _}))))
      (try
        (belief {@self tell ? _ /succ /caused_by ?set-mealtimes}
          (effects
            (begin-belief {?home breakfast-hour (clock (household-breakfast-hour) 0)})
            (begin-belief {?home lunch-hour (clock (household-lunch-hour) 0)})
            (begin-belief {?home supper-hour (clock (household-supper-hour) 0)})
            (set-outcome ?set-mealtimes /succ)))))))
