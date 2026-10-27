; ----------------------------------------------------------------------------
; bury ?corpse - the priest's rite over a body: walk to the nearest church he knows while the
; body is out of his reach (bodies are carried to a church, convey-corpse), BURY it once it is
; within reach, then tell whoever is present that the interment is done. BURY tells him the
; body is buried, which discharges his obligation (reflexes/obligation-burial.mc).
; ----------------------------------------------------------------------------

(task {@self bury ?corpse}:?bury
  (tar [k human] @object)
  (and
    (try
      (role @self (not (spatial @self can-reach ?corpse))
                  -{@self BURY ?corpse /succ /caused_by ?bury}
        (role ?church [k church-building] (select (score (near @self ?church)) (policy roulette unknown-last))
          (effects (maintain-proposal {@self go-to ?church})))))
    (try
      (role @self (spatial @self can-reach ?corpse)
                  -{@self BURY ?corpse /succ /caused_by ?bury}
        (effects (maintain-proposal {@self BURY ?corpse}))))
    (try
      (role @self {@self BURY ?corpse /succ /caused_by ?bury}
                  -{@self tell ? /succ /caused_by ?bury}
        (effects (maintain-proposal {@self tell (msg /utterable [] {?corpse internment [k buried]}) _}))))
    (try
      (role @self {@self tell ? /succ /caused_by ?bury}
        (effects (set-outcome ?bury /succ))))))
