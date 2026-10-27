; ----------------------------------------------------------------------------
; seek-company (driver). A friend in the same room, and news of his own the friend has not heard:
; @self hails him (preparation) and, once they are talking, holds the conversation (converse with no
; errand of its own). What is said in it is converse's: the answers and each party's next move,
; until nobody has anything left to say.
; ----------------------------------------------------------------------------

(driver seek-company
  (role @self {@self age ?age}
    (role ?friend {@self (closeness-labels friend) ?friend} {?friend isa [k human], condition [k alive]}
                  (spatial ?friend co-located @self)
      (bind (pick-untold-belief /news ?friend) ?untold)
      (when (and (substantial ?untold) (>= ?age 12)))
      (declare-utility want)
      (stable-or
        (try
          (when (not (engaged-with ?friend)))
          (effects (maintain-proposal {@self hail ?friend})))
        (try
          (role @self {@self hail|take-up ?friend /succ /past}
            (bind (conversation-of @self) ?talk)
            (when (engaged-with ?friend))
            (effects (maintain-proposal {@self converse ?talk}))))))))
