; ----------------------------------------------------------------------------
; catch_up (npc-think, window-start). An NPC shares their OWN recent news (a new
; spouse / fiancee / child / friendship) with a handful of their friends / lovers
; / fiancees. The (catch-up @self) effect samples <= 4 listeners itself from
; @self's own circle and relays the bare {@self <label> <person>} fact (no heavy
; profile sync). Self-news naturally cascades onward as gossip: @self is already a
; known friend of each listener, so a listener can pass "did you hear, X had a
; child" along.
;
; A mental change (news reaches @self's circle), so npc-think; fired once per NPC
; per window (sim-window-start). CAST-FREE: @self is the deliberating NPC, and the
; relay reaches @self's social graph - no second binding role (the partner is
; sampled inside the verb). RELATIONAL (graph reach, not a physical room) - a
; co-present "catch up at the venue" form is a future refinement. The gate is an
; extraversion-weighted chance on top of the has-a-friend filter.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event catch_up
  (sim-window-start)
  (nl         "@self catches up with friends")
  (rng-stream behaviour)

  (roles
    (role @self (template any_human)
                (>= (years-old @self) 12)
                (believes @self {@self friend ?})
                (chance (* 0.25 (+ 0.5 (attr @self enthusiasm))))))

  (effects
    (catch-up @self)
    (log _catch_up @self)))
