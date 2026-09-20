; ----------------------------------------------------------------------------
; PUT ?item ?dest - the unpresented shortcut: the thing is now at ?dest. No reach, no
; hand travel. It absorbs hsim's LEFT-PUT / RIGHT-PUT and DROP, which were never three
; deeds: dropping is putting where you stand.
;
; THE HAND IS DERIVED, only so its grip can be cleared, which is why this act is not
; sided and sits on the body motor. PUT and UNGRASP carrying different motors is not a
; breach of "a motor is LOD-independent" - that rule binds ONE action across LODs, and
; these are two actions (action_unification_plan.md 5.3).
;
; ?cell IS A CLAIMED CELL - the task claimed it with (rest-cell ..) and hands it in - so
; the thing is put down on a table or on the floor of a room, never vaguely in it.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")

(npc-action {@self PUT ?item ?cell}:?put
  (lod unpresented)
  (motor body)
  (obs)
  (tar @excl)
  (duration (seconds 1 min))

  (init
    (if (unsubstantial (spatial ?item gripped-by /env))
        (then (set-outcome ?put /fail))))

  (effects
    ; You must be where the thing is going: the shortcut skips the reach, not the journey.
    (check (overlaps ?cell (spatial @self space)))
    (release-grip ?item ?cell)
    (set-outcome ?put /succ)))
