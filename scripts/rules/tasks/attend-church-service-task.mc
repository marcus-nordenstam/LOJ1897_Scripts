; ----------------------------------------------------------------------------
; attend-church-service - get into the nave of a church and WORSHIP there. Raised by
; want-worship, sunday-observance and rehabilitation. In a nave he worships; getting there is
; enter-room's, and an outing enter-room fails is failed.
; ----------------------------------------------------------------------------

(task {@self attend-church-service}:?attend-church-service
  (cease (if {@self WORSHIP /succ /caused_by ?attend-church-service}
             (then (set-outcome ?attend-church-service /succ))))
  (preemptive-or
    (try (role @self (stands-in-room [k nave])
           (effects (maintain-proposal {@self WORSHIP}))))
    (try (role @self {@self locate-room [k church-building] [k nave] /fail /caused_by ?attend-church-service}
           (effects (set-outcome ?attend-church-service /fail))))
    (try (effects (maintain-proposal {@self locate-room [k church-building] [k nave]})))))
