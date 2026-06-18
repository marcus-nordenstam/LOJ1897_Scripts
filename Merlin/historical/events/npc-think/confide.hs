; ----------------------------------------------------------------------------
; confide (npc-think). An NPC shares ONE private self-fact (their calling - the
; life passion they would not broadcast) with ONE close friend. Strictly 1:1 (you
; confide in one person, you do not announce); the (confide ?actor) effect picks a
; single confidant from the actor's friends / lovers / fiancees. The rarest of
; the conversation events - intimacy, not chatter - so the lowest chance.
;
; A mental change (the confidant learns a private fact), so npc-think. Fired by
; the per-NPC emergent pass, MONTHLY: the low extraversion-weighted chance on top
; of the has-a-friend gate. RELATIONAL (you confide in someone you trust, not
; whoever shares a room) - co-presence is not the right gate for intimacy.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event confide
  (sim-window-start)
  (nl         "@self confides in a close friend")
  (rng-stream behaviour)

  (roles
    (role @self (template any_human)
                (>= (years-old @self) 16)
                (believes @self {@self friend ?})
                (chance (* 0.08 (+ 0.5 (attr @self enthusiasm))))))

  (effects
    (confide @self)
    (log _confide @self)))
