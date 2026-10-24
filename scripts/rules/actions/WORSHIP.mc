; ----------------------------------------------------------------------------
; WORSHIP - the service, proposed by attend-church-service once he stands in a nave. The
; {@self WORSHIP} act belief IS the service memory: days-since-last reads it for the
; churchgoing pressure and the piety classifiers for the gist. (obs): the congregation sees
; him at it while it runs, which is how a neighbour comes to judge his piety.
; ----------------------------------------------------------------------------

(action {@self WORSHIP}:?WORSHIP
  (motor body)
  (obs)
  (duration (seconds 90 min))
  (init (check (stands-in-room [k nave])))
  (effects
    (set-outcome ?WORSHIP /succ)))
