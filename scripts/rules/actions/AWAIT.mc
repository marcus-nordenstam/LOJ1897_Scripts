; ----------------------------------------------------------------------------
; AWAIT ?target - stand facing ?target, waiting on him. It holds the legs until its proposer
; withdraws it: unpresented he turns to face ?target at the start, presented he keeps
; turning to face him as he moves.
; ----------------------------------------------------------------------------

(action {@self AWAIT ?target}:?AWAIT
  (motor legs)
  (obs)
  (tar [k human] @object)
  (duration procedural)
  (presentation
    (anim-male Motion_Male_Idle_02)
    (anim-female Motion_Female_Idle_01)
    (anim-flags pingpong reset randomize_start)
    (preroll 0.0) (in 0.2) (out 0.2))
  (init
    (if (unpresented-lod)
        (then (face-toward @self ?target))))
  (effects
    (if (presented-lod)
        (then (steer-facing @self ?target)))))
