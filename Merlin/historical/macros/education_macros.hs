; ----------------------------------------------------------------------------
; education_macros.hs - the schooling credential sequence (schooling.hs).
;
; (graduate-from-study): end the ongoing {@self study <curriculum>} interval
; (unforgettable, so the schooling years survive as queryable history) and
; mint / raise the {@self skilled_in <curriculum> <band>} credential - primary
; graduates novice, everything above trained (the band that trips the
; physician / lawyer / scholar identities + the prestige bump). MONOTONIC:
; never downgrades a skill a job pushed higher (competence-rank compares the
; held band). A studied UNIVERSITY SUBJECT (a discipline, not the primary /
; secondary tier) also kindles a standing interest - it maintains the skill
; against atrophy AND unlocks derive_calling (skilled_in >= trained AND an
; interest), the educated-poisoner archetype's root. No-op when not enrolled.
; ----------------------------------------------------------------------------

(define-macro graduate-from-study ()
  ; The enrolment is optional (No-op when not enrolled): the walk binds ?curriculum
  ; and zero matches skip the body.
  (for-each ?stb (every {@self study ?})
    ?stb.target: ?curriculum
    (if (is-kind ?curriculum)
        (then
          (competence-rank (any {@self skilled_in ?curriculum}).auxiliary): ?cur_rank
          (if (is-a ?curriculum [k primary_school_curriculum]) (then 1) (else 0)): ?is_primary
          (end-belief {@self study ?curriculum} /salience unforgettable)
          ; Monotonic credential (novice 0 / trained 1 / expert 2).
          (if (< ?cur_rank (- 1 ?is_primary))
              (then
                (if (>= ?cur_rank 0)
                    (then (end-belief {@self skilled_in ?curriculum} /salience unforgettable)))
                (begin-belief {@self skilled_in ?curriculum
                               (if (>= ?is_primary 1)
                                   (then [k competence_level novice])
                                   (else [k competence_level trained]))})))
          ; A university discipline kindles the standing interest.
          (if (not (or (is-a ?curriculum [k primary_school_curriculum])
                       (is-a ?curriculum [k secondary_school_curriculum])))
              (then (begin-belief {@self interest ?curriculum})))))))

; (competence-rank ?band): the monotonic rank of a competence band (novice 0 /
; trained 1 / expert 2), -1 when unheld. Folds the old C++ op into a (lookup)
; over the band_rank table (lookup_tables.hs).
(define-macro competence-rank (?band)
  (table-lookup band_rank band ?band rank -1))
