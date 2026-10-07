; ----------------------------------------------------------------------------
; attend-church-service - get into the nave of a church and WORSHIP there. Raised by
; want-worship, sunday-observance and rehabilitation. In a nave he worships; in a church he
; goes to its nave, locating one he does not know; a church he finds no nave in fails the
; outing, as does a town search that finds no church.
; ----------------------------------------------------------------------------

(task {@self attend-church-service}:?attend-church-service
  (cease (if {@self WORSHIP /succ /caused_by ?attend-church-service}
             (then (set-outcome ?attend-church-service /succ))))
  (and
    (try
      (when (stands-in-room [k nave]))
      (effects (maintain-proposal {@self WORSHIP})))
    (try
      (role ?church [k church-building] (spatial @self building ?church)
        (role ?nave [k nave] (spatial ?nave building ?church)
                             (select (score (near @self ?nave)) (policy roulette unknown-last))
          (when (not (stands-in-room [k nave])))
          (effects (maintain-proposal {@self go ?nave})))))
    (try
      (role ?church [k church-building] (spatial @self building ?church)
        (role @self -{@self locate [k nave] ?church /fail}
          (when (not (stands-in-room [k nave]))
                (not (spatial ?church room [k nave])))
          (effects (maintain-proposal {@self locate [k nave] ?church})))))
    (try
      (role ?church [k church-building] (spatial @self building ?church)
        (role @self {@self locate [k nave] ?church /fail}
          (effects (set-outcome ?attend-church-service /fail)))))
    (try
      (role ?church [k church-building] (select (score (near @self ?church)) (policy roulette unknown-last))
        (when (not (stands-in-building [k church-building])))
        (effects (maintain-proposal {@self go ?church}))))
    (try
      (role @self -{@self find-building [k church-building] ? /fail}
        (no-role [k church-building])
        (when (not (stands-in-building [k church-building])))
        (effects (maintain-proposal {@self find-building [k church-building] (current-exterior @self)}))))
    (try
      (role @self {@self find-building [k church-building] ? /fail}
        (no-role [k church-building])
        (effects (set-outcome ?attend-church-service /fail))))))
