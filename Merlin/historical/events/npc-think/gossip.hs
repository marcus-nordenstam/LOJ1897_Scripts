; ----------------------------------------------------------------------------
; gossip (npc-think). An NPC passes the single most gossip-worthy thing they know
; ABOUT SOMEONE ELSE (a witnessed scandal preferred over mere relationship news)
; to a handful of their friends / lovers / fiancees. This is the bounded
; replacement for the deleted witness_propagate full-circle broadcast: the
; (gossip ?actor) effect samples <= 4 listeners itself, dedups, and - crucially -
; files the gossiped-about party as an acquaintance in each listener's mind, so a
; listener who only HEARD the rumour can re-gossip it next month. That is what
; lets a scandal cascade outward through the subject's widening acquaintance
; network, a few ties at a time, instead of reaching everyone at once.
;
; A mental change (beliefs land in listeners), so npc-think. Fired by the per-NPC
; emergent pass, MONTHLY: the (chance) is extraversion-weighted (enthusiasm +
; assertiveness) on top of the structural has-a-friend gate. RELATIONAL (the
; relay reaches the actor's circle, not a physical room) - the few-ties-at-a-time
; spread is the propagation governor, not co-presence.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event gossip
  (sim-window-start)
  (nl         "@self spreads gossip among friends")
  (rng-stream behaviour)

  (roles
    (role @self (template any_human)
                (>= (years-old @self) 12)
                (believes {@self friend ?})
                (chance (* 0.3
                           (+ 0.5 (attr @self enthusiasm))
                           (+ 0.5 (attr @self assertiveness))))))

  (effects
    (gossip @self)
    (log _gossip @self)))
