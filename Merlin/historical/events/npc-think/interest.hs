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
  (long-term-think)
  (rng-stream behaviour)

  ; The child (@self) is the subject; a known mother gates it (births always seed
  ; one), and the effect reads both parents. age / politeness-weighted chance are
  ; non-belief ops -> (when). politeness amplifies - the conforming child takes up
  ; the parent's hobby, the contrarian rarely.
  (roles
    (role @self (template any_human)
                (believes {@self mother ?})))

  (when (and (>= (years-old @self) 3)
             (<= (years-old @self) 14)
             (chance (* 0.015 (+ 0.3 (attr @self politeness))))))

  (effects
    (seed-interest-from-parents @self)
    ))

; --- peer_propagation: a friend's enthusiasm rubs off -----------------------
(hsim-event interest_peer_propagation
  (long-term-think)
  (rng-stream behaviour)

  ; @self is the subject; a known friend gates it and the effect reads each
  ; friend's own interests and copies one @self lacks. age + the openness x
  ; enthusiasm chance are non-belief ops -> (when).
  (roles
    (role @self (template any_human)
                (believes {@self friend ?})))

  (when (and (>= (years-old @self) 8)
             (chance (* 0.0167 (attr @self openness) (+ 0.5 (attr @self enthusiasm))))))

  (effects
    (seed-interest-from-friends @self)
    ))

; --- mentor_inspired: an apprentice catches the master's craft --------------
(hsim-event interest_mentor_inspired
  (long-term-think)
  (rng-stream behaviour)

  ; @self (the apprentice) holds a standing master bond (minted by
  ; apprenticeship_start); the effect reads the master's skilled_in + calling
  ; domains and copies one @self lacks. The openness-weighted chance -> (when).
  (roles
    (role @self (template any_human)
                (believes {@self master ?})))

  (when (chance (* 0.025 (+ 0.3 (attr @self openness)))))

  (effects
    (seed-interest-from-mentor @self)
    ))

; --- temperament_drift: the residual openness-driven catch-all --------------
(hsim-event interest_temperament_drift
  (long-term-think)
  (rng-stream behaviour)

  ; The only non-relational path: @self drifts into a brand-new interest with no
  ; specific source, sampled at random. No belief filter; age + the openness-squared
  ; chance are non-belief ops -> (when). Gated HARD on openness so only the
  ; genuinely curious drift - trait-rooted, not bare chance.
  (roles
    (role @self (template any_human)))

  (when (and (>= (years-old @self) 10)
             (chance (* 0.0083 (attr @self openness) (attr @self openness)))))

  (effects
    (acquire-interest @self)
    ))

; --- interest_lapses: an unskilled interest fades --------------------------
(hsim-event interest_lapses
  (long-term-think)
  (rng-stream behaviour)

  ; @self holds at least one interest; low rate. The effect ends one interest whose
  ; domain @self is NOT skilled_in - a skilled domain is settled identity and is
  ; exempt. No-op (fires, mints nothing) if every interest is skill-backed.
  (roles
    (role @self (template any_human)
                (believes {@self interest ?})))

  (when (chance 0.0025))

  (effects
    (lapse-interest @self)
    ))
