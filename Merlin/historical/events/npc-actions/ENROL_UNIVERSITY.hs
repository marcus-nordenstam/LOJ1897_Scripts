; ----------------------------------------------------------------------------
; enrol_university (npc-action) - the ACT half of the university-enrolment split.
;
; The enrolment decision (schooling.hs enroll_university) minted {@self goal
; {@self ENROL_UNIVERSITY}}. The go/dwell think half lives in
; npc-think/schooling_errands.hs; this is the matriculation completion at the
; school. Unlike ENROL_PRIMARY / ENROL_SECONDARY (ENROL_PRIMARY_AND_SECONDARY.hs,
; a bare curriculum mint), university also picks a SUBJECT.
; ----------------------------------------------------------------------------

(npc-action {@self ENROL_UNIVERSITY}
  (duration 60)
  (effects
    ; The SUBJECT is interest-led (the class gate decided WHETHER you attend;
    ; interest decides WHAT you read), falling back to a random discipline.
    ; The primary / secondary curricula are tiers, not disciplines - excluded.
    ; Each draw is optional, so it is guard-tested inline BEFORE its must-produce
    ; (bind ...); the guard proves the draw-set non-empty, and the bound draw is a
    ; second independent pick from that same set (any member is a valid subject).
    (if (is-kind (random-held-kind-target interest [k academic_field]
                                          [k primary_school_curriculum]
                                          [k secondary_school_curriculum]))
        (then
          (random-held-kind-target interest [k academic_field]
                                         [k primary_school_curriculum]
                                         [k secondary_school_curriculum]): ?led
          (begin-belief {@self study ?led}))
        (else
          (if (is-kind (random-subkind [k academic_field]
                                       [k primary_school_curriculum]
                                       [k secondary_school_curriculum]))
              (then
                (random-subkind [k academic_field]
                                      [k primary_school_curriculum]
                                      [k secondary_school_curriculum]): ?subject
                (begin-belief {@self study ?subject})))))
    (set-outcome {@self ENROL_UNIVERSITY} succ)))
