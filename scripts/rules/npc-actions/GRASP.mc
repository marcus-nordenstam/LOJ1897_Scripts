; ----------------------------------------------------------------------------
; GRASP ?item ?hand - the hand closes on ?item and controls it. ONE act, both LODs,
; both hands: it absorbs hsim's LEFT-TAKE / RIGHT-TAKE and the isim GRASP handler.
;
; THE HAND IS AN ARGUMENT, not part of the label. (sided aux ..) resolves the engaged
; motor per belief from the side-bearing value in the aux slot, so one action serves
; both hands and the two labels disappear (action_unification_plan.md 5.2 finding 1).
;
; Presented, the task has already looked, turned and reached, so the hand is at the
; thing; unpresented, co-location is the whole precondition. THE GRIP IS THE SAME
; EITHER WAY, which is why this body does not branch - only the picture does.
;
; Its .act said run = 0 (the presented gesture is instantaneous once the reach has
; arrived) while hsim's TAKE was a minute. The minute stands: it is the scheduled
; length, and the two cannot be stated together until a (duration ..) expression can
; branch on the LOD (2.3).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")

(npc-action {@self GRASP ?item ?hand}:?grasp
  (sided aux left-hand right-hand)
  (obs)
  (tar @excl)
  (duration (seconds 1 min))
  (presentation
    (anim-right right_hand_grip)
    (anim-flags loop reset)
    (preroll 0.0) (in 0.05) (out 0.05))

  (effects
    ; The proposer's job, asserted here: a rule that proposes a grasp it cannot reach,
    ; or with a full hand, is the authoring error and not this act's problem.
    (check (spatial ?item co-located @self /env))
    (check (empty (spatial ?hand grip /env)))
    (grip-into-hand ?item ?hand)
    ; A thing in a hand is a thing you can see - which matters when it was STOWED and
    ; hidden a moment ago. The handler wrote this flag too, and both LODs need it: it is
    ; what a room walk reads, not what the renderer draws.
    (set-hidden ?item @false)
    (if (presented-lod)
        (then (attach-to-socket ?item @self (side ?hand))
              (set-renderable ?item @true)))
    (set-outcome ?grasp /succ)))
