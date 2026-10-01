; ----------------------------------------------------------------------------
; CLOSE ?thing - OPEN's mirror: the part slides or swings back to its shut pose, and it
; reads shut only when it arrives there - a half-shut door is still a passable gap.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

(action {@self CLOSE ?thing}:?CLOSE
  (motor right-hand legs)
  (obs)
  (tar [k object] @object @excl)
  (duration (open_seconds))
  (cap-outcome succ)
  (presentation
    (anim right_hand_grip)
    (preroll 0.0) (in 0.2) (out 0.2))

  (init
    (check (spatial ?thing co-located @self /env)))

  (effects
    (articulate ?thing (max 0.0 (- (attr ?thing open-amount) (/ (act-dt) (open_seconds)))))
    (if (<= (attr ?thing open-amount) 0.0)
        (then (set-outcome ?CLOSE /succ)))))
