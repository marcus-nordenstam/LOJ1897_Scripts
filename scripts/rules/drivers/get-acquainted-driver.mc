; ----------------------------------------------------------------------------
; get-acquainted-driver - an acquaintance of @self's who is not yet a friend is here, and there is
; something about himself @self has not told him: @self gets to know him (tasks/
; get-acquainted-task.mc). One at a time: of all such men here, the one most worth pursuing, the nearest among equals.
; ----------------------------------------------------------------------------

(driver get-acquainted-driver
  (role @self {@self age ?age} -{@self company [k crowded]}
    (role ?other {@self acquaintance ?other} -{@self (closeness-labels friend) ?other}
                 {?other isa [k human], condition [k alive]}
                 (spatial ?other co-located @self)
                 (substantial (disclosure-for ?other))
                 (select (score (partner-pick-score ?other (k-get-acquainted-value))) (policy argmax))
      (when (>= ?age 12))
      (declare-utility want (pursuit-worth ?other (k-get-acquainted-value)))
      (effects (maintain-proposal {@self get-acquainted ?other} /quit-trying-on-fail)))))
