; ----------------------------------------------------------------------------
; catch-up-driver - a friend of @self's is here, or in a talk with him, and @self has news he does
; not know, or @self is lonely and has not caught up with him for (catch-up-interval-days): @self
; catches up with him (tasks/catch-up-task.mc). A catch-up under way is held until it concludes:
; telling the last of the news is when it asks his. In a talk with him he has not caught up yet -
; outbid while he was at it - he still wants to.
; ----------------------------------------------------------------------------

(include "../../macros/social-macros.mc")

(driver catch-up-driver
  (role @self {@self age ?age} -{@self company [k crowded]}
    (role ?friend {@self (closeness-labels friend) ?friend} {?friend isa [k human], condition [k alive]}
                  (or (spatial ?friend co-located @self) (conversing-with @self ?friend))
      (when (and (>= ?age 12)
                 (or (substantial (news-for ?friend))
                     (substantial (any {@self catch-up ?friend}))
                     (and (conversing-with @self ?friend) (not (caught-up ?friend))))))
      (declare-utility want (pursuit-utility ?friend (k-catch-up-value)))
      (effects (maintain-proposal {@self catch-up ?friend} /quit-trying-on-fail)))))

(driver lonely-catch-up-driver
  (role @self {@self company [k lonely|isolated]}
              {@self age ?age}
              {@self enthusiasm ?enthusiasm}
              {@self withdrawal ?withdrawal}
    (role ?friend {@self (closeness-labels friend) ?friend} {?friend isa [k human], condition [k alive]}
                  (spatial ?friend co-located @self)
      (when (and (>= ?age 12)
                 (>= (days-since-last {@self catch-up ?friend /succ /ever}) (catch-up-interval-days))))
      (declare-utility want (pursuit-utility ?friend (company-value ?enthusiasm ?withdrawal)))
      (effects (maintain-proposal {@self catch-up ?friend} /quit-trying-on-fail)))))
