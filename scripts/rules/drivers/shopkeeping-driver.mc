; ----------------------------------------------------------------------------
; shopkeeping - whoever runs a shop, proprietor or clerk, takes stock once a month
; (tasks/take-stock-task.mc) and keeps a till in it (tasks/open-till-task.mc). Taking stock
; is how the keeper's beliefs about his shelves stay honest; the shop's stock is the only
; source of goods, so it cannot wait on the labour market hiring clerks.
; ----------------------------------------------------------------------------

(driver plan-stocktake
  (cooldown 1 m try-until-succ)
  (rng-stream behaviour)
  (role @self {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
    (role ?job {@self job ?job}
      (role ?org {?job org ?org}
        (role ?wp {?org workplace ?wp}
          (when (and (is-a ?wp [k shop])
                     (>= (days-since-last {@self STOCKTAKE /succ /ever}) 1)))
          (declare-utility duty)
          (effects (maintain-proposal {@self take-stock ?wp})))))))

; A shop its keeper stands in with no till he knows of gets one: buyers pay into it.
(driver plan-open-till
  (role @self {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
    (role ?job {@self job ?job}
      (role ?org {?job org ?org}
        (role ?wp {?org workplace ?wp} (spatial @self building ?wp)
          (no-role [k pile] {?norole content-kind [k coin]}
                            (spatial ?norole building ?wp)
                            (unknown (spatial ?norole gripped-by)))
          (when (is-a ?wp [k shop]))
          (declare-utility duty)
          (effects (maintain-proposal {@self open-till ?wp})))))))
