; ----------------------------------------------------------------------------
; WORSHIP - the service, proposed by attend-church-service once he stands in a nave. The
; {@self WORSHIP} act belief IS the service memory: days-since-last reads it for the
; churchgoing pressure, classify-piety and the devoutness classifiers for the gist, and the
; congregation witnesses it engine-side at completion.
; ----------------------------------------------------------------------------

(action {@self WORSHIP}:?WORSHIP
  (motor body legs)
  (duration (seconds 90 min))
  (init (check (stands-in-room [k nave])))
  (effects
    (set-outcome ?WORSHIP /succ)))
