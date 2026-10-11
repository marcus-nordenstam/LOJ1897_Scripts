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
;                          (reads the master's skilled-in / calling domains).
;   - temperament_drift  : the residual catch-all - a highly-open NPC drifts into
;                          a brand-new interest for curiosity's own sake (still a
;                          random sample, but openness-gated, not bare chance).
;
; and interest-lapses replaces interest_lost: an unskilled interest can be shed,
; but one the NPC has built into a skill (skilled-in on the same domain, S4) is
; settled identity and never lapses (the C++ effect does that filtering).
;
; The education-exposure path (a pupil picks up a school-subject interest) is
; DEFERRED: there is no student-enrollment substrate yet - children are not
; `member-of` their school, so the gate has nothing to read. Add it when school
; enrollment lands.
;
; Provenance via the belief's /causes link (which source the interest came from)
; is deferred to S7 (family-alignment); S3 mints the bare belief, matching the
; S4 derive_skills precedent.
; ----------------------------------------------------------------------------


; --- parental_seeding: a child adopts one of a parent's interests ------------
(think interest-parental-seeding
  (cooldown 1 m try-once)
  (rng-stream behaviour)

  ; The child (@self) is the subject; a known mother gates it (births always seed
  ; one), and the effect reads both parents. His age rides the @self role; the
  ; politeness-weighted chance is a non-belief op -> (when). politeness amplifies - the conforming child takes up
  ; the parent's hobby, the contrarian rarely.
  (role @self {@self politeness ?politeness}
              {@self age ?age}
              {@self mother ?}

    (when (and (>= ?age 3)
               (<= ?age 14)
               (chance (* 0.015 (+ 0.3 ?politeness)))))

    (effects
      ; One novel domain copied off a parent's interests (a 50/50 pick when both
      ; parents offer one) - the hobbies the child grows up around. Each rule
      ; guards its pick so a parent with nothing novel just drops out.
      (any {@self mother ?mother=@nothing})
      (any {@self father ?father=@nothing})
      (tolerate (random-unheld-kind-target ?mother interest interest)): ?dm
      (tolerate (random-unheld-kind-target ?father interest interest)): ?df
      (cond
        (case (is-kind ?dm)
          (if (and (is-kind ?df) (chance 0.5))
              (then (begin-belief {@self interest ?df}))
              (else (begin-belief {@self interest ?dm}))))
        (case (is-kind ?df)
          (begin-belief {@self interest ?df})))
      )))

; --- peer_propagation: a friend's enthusiasm rubs off -----------------------
(think interest-peer-propagation
  (cooldown 1 m try-once)
  (rng-stream behaviour)

  ; @self is the subject; a known friend gates it and the effect reads each
  ; friend's own interests and copies one @self lacks. His age rides the @self role;
  ; the openness x enthusiasm chance is a non-belief op -> (when).
  (role @self {@self openness ?openness}
              {@self enthusiasm ?enthusiasm}
              {@self age ?age}
              {@self friend ?}
    ; The friend whose enthusiasm rubs off - a uniform pick over the circle.
    (role ?friend {?friend isa [k human], condition [k alive]}
      {@self friend ?friend}
      (select (score 1) (policy roulette))

      (when (and (>= ?age 8)
                 (chance (* 0.0167 ?openness (+ 0.5 ?enthusiasm)))))

      (effects
        (random-unheld-kind-target ?friend interest interest): ?d
        (if (is-kind ?d)
            (then (begin-belief {@self interest ?d})))
        ))))

; --- mentor_inspired: an apprentice catches the master's craft --------------
(think interest-mentor-inspired
  (cooldown 1 m try-once)
  (rng-stream behaviour)

  ; @self (the apprentice) holds a standing master bond (minted by
  ; apprenticeship_start); the effect reads the master's skilled-in + calling
  ; domains and copies one @self lacks. The openness-weighted chance -> (when).
  (role @self {@self openness ?openness} 
              {@self master ?master}

    (when (chance (* 0.025 (+ 0.3 ?openness))))

    (effects
      ; The master's craft becomes the apprentice's casual interest (which
      ; interest_deepens can later raise to a skill of its own).
      (random-unheld-kind-target ?master interest skill-level calling): ?d
      (if (is-kind ?d)
          (then (begin-belief {@self interest ?d})))
      )))

; --- temperament_drift: the residual openness-driven catch-all --------------
(think interest-temperament-drift
  (cooldown 1 m try-once)
  (rng-stream behaviour)

  ; The only non-relational path: @self drifts into a brand-new interest with no
  ; specific source, sampled at random. His age rides the @self role; the
  ; openness-squared chance is a non-belief op -> (when). Gated HARD on openness so only the
  ; genuinely curious drift - trait-rooted, not bare chance.
  (role @self {@self openness ?openness}
              {@self age ?age}

    (when (and (>= ?age 10)
               (chance (* 0.0083 ?openness ?openness))))

    (effects
      ; A brand-new interest sampled off the whole domain axis (leaf-only, so a
      ; category node is never picked); idempotent per domain at commit.
      (random-subkind [k domain]): ?d
      (if (is-kind ?d)
          (then (begin-belief {@self interest ?d})))
      )))

; --- interest-lapses: an unskilled interest fades --------------------------
(think interest-lapses
  (cooldown 1 m try-once)
  (rng-stream behaviour)

  ; @self holds at least one interest; low rate. The effect ends one interest whose
  ; domain @self is NOT skilled-in - a skilled domain is settled identity and is
  ; exempt. No-op (fires, mints nothing) if every interest is skill-backed.
  (role @self 
              {@self interest ?}

    (when (chance 0.0025))

    (effects
      ; Drop one interest never built into a skill (an overlapping skilled-in
      ; domain is settled identity - exempt). Unforgettable: "I used to be keen
      ; on botany" survives the sleep sweep as history.
      (random-unbacked-kind-target interest skill-level): ?d
      (if (is-kind ?d)
          (then (end-belief {@self interest ?d} [/salience unforgettable])))
      )))
