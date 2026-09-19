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
; ?dest IS A SPACE, which is what every caller hands it and what the spatial write
; takes. The plan's cell form - a thing is put down on a table, not vaguely in a room -
; arrives with the env grid (section 10), and its prerequisite is unimplemented.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")

(npc-action {@self PUT ?item ?dest}:?put
  (lod unpresented)
  (motor body)
  (obs)
  (tar @excl)
  (duration (minutes 1))

  (init
    (if (unsubstantial (spatial ?item gripped-by /env))
        (then (set-outcome ?put /fail))))

  (effects
    ; You must be where the thing is going. hsim's PUT asserted this and it stays true:
    ; the shortcut skips the reach, not the journey.
    (check (= (spatial @self space) ?dest))
    (release-grip ?item ?dest)
    (set-outcome ?put /succ)))
