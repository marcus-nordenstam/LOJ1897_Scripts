; ----------------------------------------------------------------------------
; Gossip. An NPC passes the single most gossip-worthy thing they know ABOUT
; SOMEONE ELSE (a witnessed scandal preferred over mere relationship news) to a
; handful of their friends / lovers / fiancees. This is the bounded replacement
; for the deleted witness_propagate full-circle broadcast: the (gossip ?actor)
; effect samples <= 4 listeners itself, dedups, and - crucially - files the
; gossiped-about party as an acquaintance in each listener's mind, so a listener
; who only HEARD the rumour can re-gossip it next month. That is what lets a
; scandal cascade outward through the subject's widening acquaintance network, a
; few ties at a time, instead of reaching everyone at once.
;
; Per-mind (organizer-driven): role-0 enumerates candidate gossips; the effect
; reads the actor's own circle + about-others beliefs from the actor's mind.
; The (chance) is extraversion-weighted (enthusiasm + assertiveness) on top of
; the structural gate (has at least one friend). Fires monthly.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event gossip
  (nl         "?actor spreads gossip among friends")
  (kind       _gossip)
  (schedule   (monthly))
  (band      afternoon)
  (rng-stream behaviour)

  (roles
    (role ?actor (template any_human)
                 (>= (years-old ?self) 12)
                 (believes ?self {@self friend ?})
                 (chance (* 0.3
                            (+ 0.5 (attr ?self enthusiasm))
                            (+ 0.5 (attr ?self assertiveness))))))

  (when (alive ?actor))

  (effects
    (gossip ?actor)
    (log _gossip ?actor)))
