; ----------------------------------------------------------------------------
; get-acquainted-driver - an acquaintance of @self's who is not yet a friend is here, and there is
; something about himself @self has not told him: @self gets to know him (tasks/
; get-acquainted-task.mc). One at a time: of all such men he sees, the one most worth pursuing - not
; the nearest, which changes with every step he takes. Only a man he may hail (hailable): one who
; turned his hail down is let be while he is in a conversation. Seen to start, he need not stay in
; sight while @self walks to him.
; ----------------------------------------------------------------------------

(driver get-acquainted-driver
  (belief {@self age ?age} -{@self company [k crowded]}
    (role ?other {@self acquaintance ?other} -{@self (closeness-labels friend) ?other}
                 {?other isa [k human], condition [k alive]}
                 (or (in-one-conversation @self ?other)
                     (and (or (visible ?other) {@self get-acquainted ?other}) (hailable ?other)))
                 (substantial (disclosure-for ?other))
                 (select (score (pursuit-utility ?other (k-get-acquainted-value))) (policy argmax))
      (when (>= ?age 12))
      (declare-utility want (pursuit-utility ?other (k-get-acquainted-value)))
      (effects (maintain-proposal {@self get-acquainted ?other} /quit-trying-on-fail)))))
