; ----------------------------------------------------------------------------
; PR-skill-life S2 validation probe. Exercises the unified-domain substrate
; predicates against live substrate so a clean hsim sweep proves they evaluate
; (and the unminted ones return false without crashing).
;
;   - (has-interest ?fan academic_field): LIVE - interest beliefs exist (8113);
;     gating on the CATEGORY domain also proves is_a matches its leaves
;     (history / science / law / ...).
;   - (domain-aligns ?fan academic_field) > 0.3: LIVE via the 0.4 interest term
;     (skilled_in / calling are 0 today, so the score is exactly 0.4 here).
;   - skilled-at-or-above / practiced-recently / parent-skilled-in: UNMINTED
;     today (S4/S6 populate them), so each returns false; wrapped in (not ...)
;     so the probe still fires - proving they were invoked without crashing.
;
; Verification: skill_predicate_probe fires each june for academic-field fans
; (count > 0 in the narrative / mxlog). Once S3-S8 wire the predicates into real
; events, delete this file (and the _test_skill/ directory).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event skill_predicate_probe
  (nl       "?fan's academic-field affinity probes the S2 predicates")
  (schedule (annually june))
  (rng-stream behaviour)

  (roles
    (role ?fan (template any_human)
               (has-interest ?fan academic_field)
               (> (domain-aligns ?fan academic_field) 0.3)
               (not (skilled-at-or-above ?fan academic_field novice))
               (not (practiced-recently ?fan academic_field))
               (not (parent-skilled-in ?fan academic_field))))

  (effects
    (log _skill_predicate_probe ?fan)))
