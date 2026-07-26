; ----------------------------------------------------------------------------
; schooling_errands (npc-action) - the ACT halves of the schooling-enrolment splits.
;
; Each enrolment decision (schooling.hs enroll_primary / _secondary / _university)
; minted {@self goal {@self enrol_<level>}}. The go/dwell think half lives in
; npc-think/schooling_errands.hs; these are the matriculation completions at the
; school (the curriculum differs at commit per level).
; ----------------------------------------------------------------------------

; ----- primary -------------------------------------------------------------
(npc-action {@self enrol_primary}
  (duration 60)
  (effects
    (begin-belief {@self study [k primary_school_curriculum]})
    (set-outcome {@self enrol_primary} succ)))

; ----- secondary -----------------------------------------------------------
(npc-action {@self enrol_secondary}
  (duration 60)
  (effects
    (begin-belief {@self study [k secondary_school_curriculum]})
    (set-outcome {@self enrol_secondary} succ)))

; ----- university ----------------------------------------------------------
(npc-action {@self enrol_university}
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
          (bind (random-held-kind-target interest [k academic_field]
                                         [k primary_school_curriculum]
                                         [k secondary_school_curriculum]) ?led)
          (begin-belief {@self study ?led}))
        (else
          (if (is-kind (random-subkind [k academic_field]
                                       [k primary_school_curriculum]
                                       [k secondary_school_curriculum]))
              (then
                (bind (random-subkind [k academic_field]
                                      [k primary_school_curriculum]
                                      [k secondary_school_curriculum]) ?subject)
                (begin-belief {@self study ?subject})))))
    (set-outcome {@self enrol_university} succ)))
