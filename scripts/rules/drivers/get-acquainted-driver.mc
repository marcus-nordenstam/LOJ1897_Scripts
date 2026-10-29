; ----------------------------------------------------------------------------
; get-acquainted-driver - an acquaintance of @self's who is not yet a friend is here, and there is
; something about himself @self has not told him: @self gets to know him (tasks/
; get-acquainted-task.mc).
; ----------------------------------------------------------------------------

(driver get-acquainted-driver
  (role @self {@self age ?age}
    (role ?other {@self acquaintance ?other} -{@self (closeness-labels friend) ?other}
                 {?other isa [k human], condition [k alive]}
                 (spatial ?other co-located @self)
      (when (and (>= ?age 12) (substantial (disclosure-for ?other))))
      (declare-utility want)
      (effects (maintain-proposal {@self get-acquainted ?other} /quit-trying-on-fail)))))
