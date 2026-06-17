; ----------------------------------------------------------------------------
; reacquaint - conduct / attractiveness live re-sync.
;
; A's beliefs ABOUT a known contact B (B's conduct - honesty / piety /
; criminality / prestige / wealth - and B's attractiveness) are a snapshot taken
; the last time A and B interacted (believe_about, at betrothal / friendship /
; leisure / etc.). Without a refresh they freeze: if B's conduct drifts (B turns
; criminal, gains prestige), A keeps judging B on the stale figure, and the
; Class II standing pass (which reads those mirrored beliefs) reasons on old
; news.
;
; This re-mirrors: each year a fraction of the town re-acquaints with one of
; their known contacts and refreshes the whole profile (believe_about re-copies
; the disclosure bands, conduct + attractiveness among them). Cheap, content-only
; - no engine change - and reliable now that personally-knows + the sampler bind
; correctly. The recurring social events (leisure,
; interest_outing) already refresh co-attendees; this catches the contacts you
; do not regularly see.
;
; Topology: ?a enumerated and gated by a per-person chance (so not everyone
; reconnects); ?b a uniformly-sampled known contact.
; EMERGENT (Section 4.11): no (schedule) - fired by the per-NPC emergent pass
; (relational, personally-knows-gated, no co-presence); MONTHLY now, so the ?a
; (chance) is /12 (0.5 -> 0.04) to hold the annual reconnection volume.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event reacquaint
  (nl       "?a catches up on ?b")
  (kind [k _reacquaint])
  (band      afternoon)
  (rng-stream behaviour)

  (roles
    (role ?a (template any_human)
             (>= (years-old ?a) 18)
             (chance 0.04))
    (role ?b (template any_human)
             (not (= ?b ?a))
             (personally-knows ?a ?b)))

  (effects
    ; Re-mirror A's profile of B - refreshes the frozen conduct / attractiveness
    ; (and class / prestige / wealth) snapshot the standing pass reads.
    (believe-about ?a ?b)
    (log _reacquaint ?a)))
