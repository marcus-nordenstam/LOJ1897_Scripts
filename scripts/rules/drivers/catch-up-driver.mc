; ----------------------------------------------------------------------------
; catch-up-driver - a friend of @self's is here, and @self has news he does not know or has not
; caught up with him for (catch-up-interval-days): @self catches up with him (tasks/catch-up-task.mc).
; ----------------------------------------------------------------------------

(driver catch-up-driver
  (role @self {@self age ?age}
    (role ?friend {@self (closeness-labels friend) ?friend} {?friend isa [k human], condition [k alive]}
                  (spatial ?friend co-located @self)
      (when (and (>= ?age 12)
                 (or (substantial (news-for ?friend))
                     (>= (days-since-last {@self catch-up ?friend /succ /ever}) (catch-up-interval-days)))))
      (declare-utility want)
      (effects (maintain-proposal {@self catch-up ?friend} /quit-trying-on-fail)))))
