; ----------------------------------------------------------------------------
; STOW - ?thing goes out of the hand, onto the body, out of sight.
;
; PORTED from the C++ handler (action_unification_plan.md). The handler's init_func
; validated its arguments and rejected the act; that rejection is the (init ..)
; below, because a /fail there is what refuses an install - a (check ..) would not,
; since it compiles out under MX_SHIPPING. The handler's whole run_func is here: the
; grip moves from the hand to the MAN (the grip store is exclusive, so gripping onto
; @self drops the hand's hold on its own - there is no detach), and the thing stops
; being there to be seen. The scene half is the same two moves in pictures: off the
; hand socket, onto the body root, renderable off.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")

(npc-action {@self STOW ?thing}:?stow
  (motor mind)
  (obs)
  (tar @excl)
  (duration 0.6)
  (presentation
    (preroll 0.0) (in 0.4) (out 0.4))

  (init
    (if (unsubstantial ?thing)
        (then (set-outcome ?stow /fail))))

  (effects
    (check (= (spatial ?thing gripped-by /env) @self))
    ; THE MAN holds it now, not a hand of his. Exclusive, so this is the whole of the
    ; transfer - and (observe ..) is what makes him know he has it stowed.
    (grip-into-hand ?thing @self)
    ; Out of sight, so no room walk offers it to anyone's perception while it is in
    ; his coat. Both LODs: this is a fact about the world, not about the picture.
    (set-hidden ?thing @true)
    (if (presented-lod)
        (then (attach-to-socket ?thing @self @nothing)
              (set-renderable ?thing @false)))
    (set-outcome ?stow /succ)))
