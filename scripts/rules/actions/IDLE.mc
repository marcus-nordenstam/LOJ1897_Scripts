; ----------------------------------------------------------------------------
; idle (action) - the rest pose of a motor no act runs on.
;
; Nothing proposes this and the engine never runs it: a motor that carries no act IS
; idle, with no act and no belief on it. This declaration exists for its presentation -
; the host plays that pose on every motor that carries nothing - and it is found by the
; (idle-action) decoration, never by spelling IDLE in C++.
;
; DWELL is the opposite case and must not carry (idle-action) - staying at your post
; between duties is PURPOSEFUL, and it inherits the duty's utility, which is why a man
; does not wander off to play billiards halfway through his shift.
; ----------------------------------------------------------------------------

(action {@self IDLE ?motor}
  (duration procedural)
  (presentation
    (anim-male Motion_Male_Idle_02)
    (anim-female Motion_Female_Idle_01)
    (anim-flags pingpong reset randomize_start)
    (state standing)
    (preroll 0.0) (in inherit) (out inherit))
  (idle-action))
