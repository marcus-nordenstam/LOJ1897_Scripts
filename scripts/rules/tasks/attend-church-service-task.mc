; ----------------------------------------------------------------------------
; attend-church-service - WORSHIP in the nave of a church. Raised by want-worship,
; sunday-observance and rehabilitation. It requires that he stands in one for as long as it runs
; (stands-in-room-of), which enter-room-kind achieves before the service is proposed and again
; whenever something takes him out.
; ----------------------------------------------------------------------------

(task {@self attend-church-service}:?attend-church-service
  (running-requirements (stands-in-room-of [k nave] [k church-building]))
  (cease (if {@self WORSHIP /succ /caused_by ?attend-church-service}
             (then (set-outcome ?attend-church-service /succ))))
  (and
    (try (effects (maintain-proposal {@self WORSHIP})))
    ; STAY: he keeps to the nave while he is at it; nothing below his outing's band walks him out.
    (try (declare-utility fallback)
         (effects (maintain-proposal {@self DWELL (spatial @self space) (+ (time hour) 1)})))))
