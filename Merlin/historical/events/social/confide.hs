; ----------------------------------------------------------------------------
; Confide. An NPC shares ONE private self-fact (their calling - the life passion
; they would not broadcast) with ONE close friend. Strictly 1:1 (you confide in
; one person, you do not announce); the (confide ?actor) effect picks a single
; confidant from the actor's friends / lovers / fiancees. The rarest of the
; conversation events - intimacy, not chatter - so the lowest chance.
;
; Per-mind (organizer-driven). Fires monthly with a low extraversion-weighted
; chance on top of the has-a-friend gate.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event confide
  (nl         "?actor confides in a close friend")
  (kind       _confide)
  (schedule   (monthly))
  (rng-stream behaviour)

  (roles
    (role ?actor (template any_human)
                 (>= (years-old ?self) 16)
                 (believes ?self {@self friend ?})
                 (chance (* 0.08 (+ 0.5 (attr ?self enthusiasm))))))

  (when (alive ?actor))

  (effects
    (confide ?actor)
    (log _confide ?actor)))
