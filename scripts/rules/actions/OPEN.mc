; ----------------------------------------------------------------------------
; OPEN ?thing - swing a door open or slide a drawer out, at either LOD and for either
; actor. The body touches ground truth only: (articulate ..) moves the part's box off its
; shut pose and writes its state, and a presenting host copies the box to the mesh, so
; the player at the keys and an NPC at his desk run the same act. Presented, the effects
; tick every frame and the part moves smoothly; unpresented, the one scheduled tick steps
; the whole length and the part lands open.
;
; The lock is the PROPOSER's precondition: an NPC's rule proposes an OPEN it knows to be
; unlocked, and the player's input starts nothing on a locked target.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

(action {@self OPEN ?thing}:?OPEN
  (motor right-hand legs)
  (obs)
  (tar [k object] @object @excl)
  (duration (open_seconds))
  (cap-outcome succ)
  (presentation
    (anim right_hand_grip)
    (preroll 0.0) (in 0.2) (out 0.2))

  (init
    (check (spatial ?thing co-located @self /env))
    (check (neq (attr ?thing lock-status) [k locked])))

  (effects
    (articulate ?thing (min 1.0 (+ (attr ?thing open-amount) (/ (act-dt) (open_seconds)))))
    (if (>= (attr ?thing open-amount) 1.0)
        (then (set-outcome ?OPEN /succ)))))
