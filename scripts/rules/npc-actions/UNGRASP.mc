; ----------------------------------------------------------------------------
; UNGRASP ?item ?hand - open the hand. The thing rests where the hand IS: which cell
; that is was decided by REACH-FOR, and where the man stands was decided by go.
;
; PRESENTED ONLY, and that is not a shortcut being taken twice: unpresented has no
; reach to have placed the hand, so there is nothing to open it AT, and that LOD takes
; PUT's shortcut instead (action_unification_plan.md 5.3). The world effect is
; authored ONCE all the same - release-grip, which both call.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")

(npc-action {@self UNGRASP ?item ?hand}:?ungrasp
  (lod presented)
  (sided aux left-hand right-hand)
  (obs)
  (tar @excl)
  (duration 0)
  (presentation
    (preroll 0.0) (in 0.05) (out 0.05))

  (prelude
    (if (!= (spatial ?item gripped-by /env) ?hand)
        (then (set-outcome ?ungrasp /fail))))

  (effects
    (hand-rest-point ?hand): ?rest
    (release-grip ?item ?rest)
    (detach-entity ?item)
    ; TWO writes are required for the placement to stick: Merlin's bounds AND the GRYM
    ; TransformComponent. After the detach the scene transform still carries the
    ; hand-tip world pose, so without this the next feedback pass overwrites what we
    ; just set and the glass ends up wherever the hand was.
    (place-entity ?item ?rest)
    (set-outcome ?ungrasp /succ)))
