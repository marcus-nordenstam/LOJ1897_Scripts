; ----------------------------------------------------------------------------
; education_macros.hs - the schooling credential sequence (schooling.hs).
;
; (graduate-from-study): end the ongoing {@self study <curriculum>} interval
; (unforgettable, so the schooling years survive as queryable history) and
; mint / raise the {@self skilled-in <curriculum> <band>} credential - primary
; graduates novice, everything above trained (the band that trips the
; physician / lawyer / scholar identities + the prestige bump). MONOTONIC:
; never downgrades a skill a job pushed higher (comparing the held band's rank
; against the new one). A studied UNIVERSITY SUBJECT (a discipline, not the primary /
; secondary tier) also kindles a standing interest - it maintains the skill
; against atrophy AND unlocks derive_calling (skilled-in >= trained AND an
; interest), the educated-poisoner archetype's root. No-op when not enrolled.
; ----------------------------------------------------------------------------

(define-macro graduate-from-study ()
  ; The enrolment is optional (No-op when not enrolled): the walk binds ?curriculum
  ; and zero matches skip the body.
  (for-each ?stb (every {@self study ?})
    (bind ?stb.target ?curriculum)
    (if (is-kind ?curriculum)
        (then
          (if (table-match band_rank band (any {@self skilled-in ?curriculum}).auxiliary rank ?held_rank)
              (then ?held_rank) (else -1)): ?cur_rank
          (if (is-a ?curriculum [k primary-school-curriculum]) (then 1) (else 0)): ?is_primary
          (end-belief {@self study ?curriculum} [/salience unforgettable])
          ; Monotonic credential (novice 0 / trained 1 / expert 2).
          (if (< ?cur_rank (- 1 ?is_primary))
              (then
                (if (>= ?cur_rank 0)
                    (then (end-belief {@self skilled-in ?curriculum} [/salience unforgettable])))
                (begin-belief {@self skilled-in ?curriculum
                               (if (>= ?is_primary 1)
                                   (then [k competence-level novice])
                                   (else [k competence-level trained]))})))
          ; A university discipline kindles the standing interest.
          (if (not (or (is-a ?curriculum [k primary-school-curriculum])
                       (is-a ?curriculum [k secondary-school-curriculum])))
              (then (begin-belief {@self interest ?curriculum})))))))
