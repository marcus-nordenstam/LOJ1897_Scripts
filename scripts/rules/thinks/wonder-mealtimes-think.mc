; ----------------------------------------------------------------------------
; wonder-mealtimes - a resident who does not know his house's supper hour, and is not the one who
; sets the hours, wonders what it is; he stops when he learns it. Mealtime knowledge can never be
; permanently lost while the woman of the house lives: wondering, he finds it out
; (drivers/want-to-know-driver.mc), and the rulebook names her as the one who would know.
; ----------------------------------------------------------------------------

(think wonder-mealtimes
  (role ?home {@self home ?home}
    (and
      (try
        (role @self {@self age ?age}
                    -{@self duty-to ? set-mealtimes}
                    -{@self wonder {?home supper-hour ?}}
                    -{?home supper-hour ?}
          (when (>= ?age 3))
          (effects (begin-belief {@self wonder {?home supper-hour ?}}))))
      (try
        (role ?known {?known supper-hour ?}
                     (eq ?known ?home)
          (role @self {@self wonder {?home supper-hour ?}}:?wonder
            (effects (end-belief ?wonder))))))))
