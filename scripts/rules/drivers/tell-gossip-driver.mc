; ----------------------------------------------------------------------------
; tell-gossip-driver - a friend of @self's is here, and @self holds gossip he does not know: @self
; passes it on (tasks/tell-gossip-task.mc).
; ----------------------------------------------------------------------------

(driver tell-gossip-driver
  (role @self {@self age ?age}
    (role ?friend {@self (closeness-labels friend) ?friend} {?friend isa [k human], condition [k alive]}
                  (spatial ?friend co-located @self)
      (when (and (>= ?age 12) (substantial (gossip-for ?friend))))
      (declare-utility want)
      (effects (maintain-proposal {@self tell-gossip ?friend})))))
