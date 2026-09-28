(define-func graduate-from-study ()
  ; The enrolment is optional (No-op when not enrolled): the walk binds ?curriculum
  ; and zero matches skip the body.
  (for-each ?stb (every {@self study ?})
    (bind ?stb.target ?curriculum)
    (if (is-kind ?curriculum)
        (then
          (any {@self skilled-in ?curriculum ?held_band=@nothing})
          (if (table-match band_rank band ?held_band rank ?held_rank)
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
