; ----------------------------------------------------------------------------
; obliged-attend - an invitation to an occasion, or organizing one, obliges @self to attend it;
; attending it discharges the obligation.
; ----------------------------------------------------------------------------

(reflex {? invite @self ?occ}
  (when -{@self obliged ?occ attend})
  (effects (begin-belief {@self obliged ?occ attend})))

(reflex {@self organize ?occ}
  (when -{@self obliged ?occ attend})
  (effects (begin-belief {@self obliged ?occ attend})))

(reflex {@self attend ?occ /succ}
  (when {@self obliged ?occ attend})
  (effects (end-belief {@self obliged ?occ attend})))
