; ----------------------------------------------------------------------------
; Catch-up. An NPC shares their OWN recent news (a new spouse / fiancee / child
; / friendship) with a handful of their friends / lovers / fiancees. The
; (catch-up ?actor) effect samples <= 4 listeners itself and relays the bare
; {actor <label> <person>} fact (no heavy profile sync). Self-news naturally
; cascades onward as gossip: the actor is already a known friend of each
; listener, so a listener can pass "did you hear, ?actor had a child" along.
;
; Per-mind (organizer-driven). Extraversion-weighted chance on top of the
; has-a-friend gate. Fires monthly.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event catch_up
  (nl         "?actor catches up with friends")
  (kind       _catch_up)
  (schedule   (monthly))
  (band      afternoon)
  (rng-stream behaviour)

  (roles
    (role ?actor (template any_human)
                 (>= (years-old ?self) 12)
                 (believes ?self {@self friend ?})
                 (chance (* 0.25 (+ 0.5 (attr ?self enthusiasm))))))

  (when (alive ?actor))

  (effects
    (catch-up ?actor)
    (log _catch_up ?actor)))
