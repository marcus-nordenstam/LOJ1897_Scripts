; ----------------------------------------------------------------------------
; Ad-hoc social-outing lane (hsim_activity_lanes_plan.md, phase L3). An
; extraverted NPC (the organizer) assembles a handful of its OWN available
; friends and takes them out - to a pub in its town. Every attendee (organizer
; included) records the episodic memory {@self socialize_at <venue> /aux
; <organizer>}; the whole party shares this firing's active-day (L0), so they
; share (venue, date) - the substrate the L4 co-presence sweep reads.
;
; Organizer-driven, per-mind (core principle 2): role-0 enumerates candidate
; organizers; the effect (host-social-outing) reads the organizer's friend
; circle from the organizer's own mind and applies the availability gates
; (alive / mobile / same-town, section 3). Friends are NOT a role here, so two
; extraverts assemble overlapping-but-distinct parties with no reconciliation.
;
; The (chance) is extraversion-weighted jitter on top of the structural gate
; (has at least one friend): enthusiasm + assertiveness are the two Big Five
; extraversion aspects, so the gregarious host outings often and the reserved
; rarely. Fires monthly on the active-day bag.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event social_outing
  (nl         "?organizer takes friends out")
  (kind       _social_outing)
  (schedule   (monthly))
  (rng-stream behaviour)

  (roles
    (role ?organizer (template any_human)
                     (>= (years-old ?self) 16)
                     (believes ?self {@self friend ?})
                     (chance (* 0.5
                                (attr ?self enthusiasm)
                                (attr ?self assertiveness)))))

  (when (alive ?organizer))

  (effects
    (host-social-outing ?organizer)
    (log _social_outing ?organizer)))
