; ----------------------------------------------------------------------------
; LOOK-AT - @self puts his attention on ?target and his head round to it.
;
; PORTED from the C++ handler (action_unification_plan.md). TWO EFFECTS, one mental and one
; physical, and the mental one is the point: (push-attention ..) is what makes the
; attended-whereabouts verify notice that the thing he is looking at has moved or gone.
; The head yaw is a PART write - the head carries its own box parented to the man - so
; a man can look at something without turning his shoulders to it.
;
; PROCEDURAL: the handler returned no outcome and the .act said run = ?. A look lasts
; until the proposer stops wanting it, which is why the animation layer re-resolves the
; target's position every frame rather than this act re-aiming it.
; ----------------------------------------------------------------------------


(npc-action {@self LOOK-AT ?target}:?look
  (motor head)
  (obs)
  (tar @excl)
  (duration procedural)
  (presentation
    (proc-anim lookat)
    (preroll 0.0) (in 2) (out 2))

  ; BOTH EFFECTS ARE IN THE PRELUDE, where the handler had them - its init_func held the
  ; attention push and the yaw, and its run_func was a no-op. That is not a stylistic
  ; echo: a PROCEDURAL act has no cap, so nothing schedules a tick for it and an
  ; (effects ..) block would never run at unpresented LOD at all. The prelude runs at
  ; install in both.
  (init
    (push-attention ?target)
    ; The head only. Presented, the gaze solver aims it every frame off the
    ; proc-anim, so a write here would fight it - which is why the handler did
    ; this for UNPRESENTED actors alone.
    (if (unpresented-lod)
        (then (tolerate (face-toward (spatial @self head /env) ?target))))))
