; ----------------------------------------------------------------------------
; OPEN ?thing - swing a door open or slide a drawer out, at either LOD and for either
; actor. The body touches ground truth only: (articulate ..) (funcs/articulate.mc) moves the
; part's box off its shut pose, and a presenting host copies the box to the mesh, so the player
; at the keys and an NPC at his desk run the same act. Presented, the effects tick every frame
; and the part moves smoothly; unpresented, the one scheduled tick steps the whole length and
; the part lands open. It reads ajar only once it is fully open.
;
; A locked part does not give: the act fails, which is how a man whose belief said unlocked
; finds out otherwise. The player's input starts nothing on a locked target.
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
    (check (spatial ?thing co-located @self /env)))

  (effects
    (bind (min 1.0 (+ (attr ?thing open-amount) (/ (act-dt) (open_seconds)))) ?amount)
    (if (eq (attr ?thing lock-status) [k locked])
        (then (set-outcome ?OPEN /fail))
        (else
          (articulate ?thing ?amount)
          (if (>= ?amount 1.0)
              (then
                (set-attr ?thing opening-status [k ajar])
                (set-outcome ?OPEN /succ)))))))
