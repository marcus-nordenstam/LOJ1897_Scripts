; ----------------------------------------------------------------------------
; Interests (PR-skill-life S3). NPCs pick up - and occasionally drop -
; interests over their lives, on top of the 0-3 hereditary interests the
; `interest` attr seeds at birth. All are {@self interest <domain>} beliefs
; (the unified `domain` axis, S1), so an acquired interest is indistinguishable
; in form from a born one.
;
; S3 replaces the old chance-primary interest_acquired (which sampled a RANDOM
; domain off bare luck) with SUBSTRATE-ROOTED acquisition: the new interest is a
; SPECIFIC domain copied from a real social source the actor is tied to -
;
;   - parental_seeding   : a child takes up a parent's hobby (the deferential
;                          child more so; gated on politeness).
;   - peer_propagation   : a friend's enthusiasm rubs off (gated on
;                          openness x enthusiasm - the receptive and sociable
;                          catch more interests).
;   - mentor_inspired    : an apprentice takes an interest in the master's craft
;                          (reads the master's skilled_in / calling domains).
;   - temperament_drift  : the residual catch-all - a highly-open NPC drifts into
;                          a brand-new interest for curiosity's own sake (still a
;                          random sample, but openness-gated, not bare chance).
;
; and interest_lapses replaces interest_lost: an unskilled interest can be shed,
; but one the NPC has built into a skill (skilled_in on the same domain, S4) is
; settled identity and never lapses (the C++ effect does that filtering).
;
; The education-exposure path (a pupil picks up a school-subject interest) is
; DEFERRED: there is no student-enrollment substrate yet - children are not
; `member_of` their school, so the gate has nothing to read. Add it when school
; enrollment lands.
;
; Provenance via the belief's /causes link (which source the interest came from)
; is deferred to S7 (family_alignment); S3 mints the bare belief, matching the
; S4 derive_skills precedent.
;
; EMERGENT (Section 4.11): no (schedule) - all five fire via the per-NPC emergent
; pass (per-individual, relational-source-gated, no co-presence) on the behaviour
; rng-stream. They fire MONTHLY now, so each (chance) is /12 to preserve the
; annual cadence (interests develop over years, not months).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

; --- parental_seeding: a child adopts one of a parent's interests ------------
(hsim-event interest_parental_seeding
  (nl         "?child takes up a parent's interest")
  (kind       _interest_parental_seeding)
  (rng-stream behaviour)

  (roles
    ; A known mother gates the event (births always seed one); the effect reads
    ; both parents. politeness (deference to family / convention) amplifies -
    ; the conforming child takes up the parent's hobby, the contrarian rarely.
    (role ?child (template any_human)
                 (>= (years-old ?self) 3)
                 (<= (years-old ?self) 14)
                 (believes ?self {@self mother ?})
                 (chance (* 0.015 (+ 0.3 (attr ?self politeness))))))

  (effects
    (seed-interest-from-parents ?child)
    (log _interest_parental_seeding ?child)))

; --- peer_propagation: a friend's enthusiasm rubs off -----------------------
(hsim-event interest_peer_propagation
  (nl         "?ego catches a friend's interest")
  (kind       _interest_peer_propagation)
  (rng-stream behaviour)

  (roles
    ; openness (receptivity to the new) x enthusiasm (the sociable Extraversion
    ; aspect - more friends, more exposure). The effect reads each friend's own
    ; interests and copies one ego lacks.
    (role ?ego (template any_human)
               (>= (years-old ?self) 8)
               (believes ?self {@self friend ?})
               (chance (* 0.0167 (attr ?self openness) (+ 0.5 (attr ?self enthusiasm))))))

  (effects
    (seed-interest-from-friends ?ego)
    (log _interest_peer_propagation ?ego)))

; --- mentor_inspired: an apprentice catches the master's craft --------------
(hsim-event interest_mentor_inspired
  (nl         "?ego takes an interest in the master's craft")
  (kind       _interest_mentor_inspired)
  (rng-stream behaviour)

  (roles
    ; A standing master bond (minted by apprenticeship_start). openness
    ; amplifies. The effect reads the master's skilled_in + calling domains and
    ; copies one ego lacks (so the craft becomes the apprentice's casual
    ; interest, which interest_deepens can later raise to a skill - S6).
    (role ?ego (template any_human)
               (believes ?self {@self master ?})
               (chance (* 0.025 (+ 0.3 (attr ?self openness))))))

  (effects
    (seed-interest-from-mentor ?ego)
    (log _interest_mentor_inspired ?ego)))

; --- temperament_drift: the residual openness-driven catch-all --------------
(hsim-event interest_temperament_drift
  (nl         "?ego drifts into a new interest")
  (kind       _interest_temperament_drift)
  (rng-stream behaviour)

  (roles
    ; The only non-relational path: a brand-new interest with no specific
    ; source, sampled at random. Gated HARD on openness (openness-squared) so
    ; only the genuinely curious drift - trait-rooted, not bare chance. Lower
    ; base rate than the old generic interest_acquired (0.08).
    (role ?ego (template any_human)
               (>= (years-old ?self) 10)
               (chance (* 0.0083 (attr ?self openness) (attr ?self openness)))))

  (effects
    (acquire-interest ?ego)
    (log _interest_temperament_drift ?ego)))

; --- interest_lapses: an unskilled interest fades --------------------------
(hsim-event interest_lapses
  (nl         "?ego loses an interest")
  (kind       _interest_lapses)
  (rng-stream behaviour)

  (roles
    ; Holds at least one interest; low rate. The effect ends one interest whose
    ; domain ego is NOT skilled_in - a skilled domain is settled identity and is
    ; exempt. No-op (event fires, mints nothing) if every interest is skill-backed.
    (role ?ego (template any_human)
               (believes ?self {@self interest ?})
               (chance 0.0025)))

  (effects
    (lapse-interest ?ego)
    (log _interest_lapses ?ego)))
