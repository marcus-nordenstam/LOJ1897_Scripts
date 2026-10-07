; ----------------------------------------------------------------------------
; rehabilitation - a DISREPUTABLE man's second pull toward church: not piety but the wish to
; restore standing. It raises the same attend-church-service task the worship drives do, on
; a 15-day itch; the sources sum on the one proposal, and one service relieves them all,
; since every drive ramps with days since the last {@self WORSHIP}.
;
; The payoff needs no wiring: the services feed classify-piety, piety feeds the respectability
; band, so the more a disreputable man attends the more respectable he becomes. The scandalous
; are not cast: already ostracised, a church visit cannot lift them in one pass.
; ----------------------------------------------------------------------------

(think rehabilitation
  (cooldown 15 d try-until-succ)
  (role @self {@self isa [k human], condition [k alive]}
              {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
              {@self repute [k disreputable]}
    (when    (>= (days-since-last {@self WORSHIP /succ /ever}) 15))
    (declare-utility idle (* 10 (min (* (days-since-last {@self WORSHIP /succ /ever}) 2) 40)))
    (effects (maintain-proposal {@self attend-church-service}))))
