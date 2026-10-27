; ----------------------------------------------------------------------------
; convey-corpse ?corpse - carry the body to a church @self knows and lay it down there
; (CONVEY). Fails when he learns it was buried first.
; ----------------------------------------------------------------------------

(task {@self convey-corpse ?corpse}:?convey-corpse
  (tar ?)
  (and
    (try
      (role ?church [k church-building] (select (score (near @self ?church)) (policy roulette unknown-last))
        (when (not (is-a (spatial @self building) [k church-building])))
        (effects (maintain-proposal {@self go-to ?church}))))
    (try
      (when (is-a (spatial @self building) [k church-building]))
      (effects (maintain-proposal {@self CONVEY ?corpse})))
    (try
      (role @self {@self CONVEY ?corpse /succ /caused_by ?convey-corpse}
        (effects (set-outcome ?convey-corpse /succ))))
    (try
      (role ?corpse {?corpse internment [k buried]}
        (effects (set-outcome ?convey-corpse /fail))))))
