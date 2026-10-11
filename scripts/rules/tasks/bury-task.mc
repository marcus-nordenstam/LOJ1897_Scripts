; ----------------------------------------------------------------------------
; bury ?corpse - the priest's rite over a body: walk to the nearest church he knows while the
; body is out of his reach (bodies are carried to a church, convey-corpse), BURY it once it is
; within reach, then tell whoever is present that the interment is done. BURY tells him the
; body is buried, which discharges his obligation (reflexes/obliged-burial.mc).
; ----------------------------------------------------------------------------

(task {@self bury ?corpse}:?bury
  (tar [k human] @object)
  (and
    (try
      (role ?church [k church-building] (select (score (near @self ?church)) (policy roulette unknown-last))
        (when (and -{@self BURY ?corpse /succ /caused_by ?bury}
                   (not (spatial @self can-reach ?corpse))))
        (effects (maintain-proposal {@self go-to ?church}))))
    (try
      (when (and -{@self BURY ?corpse /succ /caused_by ?bury}
                 (spatial @self can-reach ?corpse)))
      (effects (maintain-proposal {@self BURY ?corpse})))
    (try
      (when (and {@self BURY ?corpse /succ /caused_by ?bury}
                 -{@self tell ? /succ /caused_by ?bury}))
      (effects (maintain-proposal {@self tell (utterable-msg [] {?corpse internment [k buried]}) _})))
    (try
      (when {@self tell ? /succ /caused_by ?bury})
      (effects (set-outcome ?bury /succ)))))
