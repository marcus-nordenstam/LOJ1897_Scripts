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
        (role @self -{@self tell ? _ /succ /caused_by ?set-mealtimes}
          (effects
            (maintain-proposal {@self tell (msg /utterable [] {?home breakfast-hour (household-breakfast-hour)}
                                                          {?home lunch-hour (household-lunch-hour)}
                                                          {?home supper-hour (household-supper-hour)}) _}))))
      (try
        (role @self {@self tell ? _ /succ /caused_by ?set-mealtimes}
          (effects
            (begin-belief {?home breakfast-hour (household-breakfast-hour)})
            (begin-belief {?home lunch-hour (household-lunch-hour)})
            (begin-belief {?home supper-hour (household-supper-hour)})
            (set-outcome ?set-mealtimes /succ)))))))
