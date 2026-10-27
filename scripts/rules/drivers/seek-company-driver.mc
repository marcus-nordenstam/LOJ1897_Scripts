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
      (when (>= ?age 12))
      (declare-utility want)
      (stable-or
        (try
          (bind (pick-untold-belief /news ?friend) ?untold)
          (when (and (substantial ?untold) (not (engaged-with ?friend))))
          (effects (maintain-proposal {@self hail ?friend})))
        (try
          (role @self {@self hail|take-up ?friend /succ /past}
            (bind (conversation-of @self) ?talk)
            (bind (any {@self converse ?talk}) ?converse)
            (when (and (engaged-with ?friend)
                       (is-belief ?converse)
                       (or (substantial (friend-talk-line ?talk ?friend))
                           (friend-awaits-reply ?talk ?friend))))
            (effects (maintain-proposal {@self friend-talk ?talk ?friend} /caused_by ?converse))))))))
