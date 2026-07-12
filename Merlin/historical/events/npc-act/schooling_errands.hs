; ----------------------------------------------------------------------------
; schooling_errands (npc-act) - the ACT halves of the schooling-enrolment splits.
;
; Each enrolment decision (schooling.hs enroll_primary / _secondary / _university)
; minted {@self goal {@self enrol_<level>}}. The go/dwell think half lives in
; npc-think/schooling_errands.hs; these are the matriculation completions at the
; school (the curriculum differs at commit per level).
; ----------------------------------------------------------------------------

; ----- primary -------------------------------------------------------------
(npc-act enrol_primary_act
  (when (believes {@self enrol_primary}))
  (duration 60)
  (act-effects
    (begin-belief {@self study [k primary_school_curriculum]})
    (end-act {@self enrol_primary})
    (end-goal {@self enrol_primary})))

; ----- secondary -----------------------------------------------------------
(npc-act enrol_secondary_act
  (when (believes {@self enrol_secondary}))
  (duration 60)
  (act-effects
    (begin-belief {@self study [k secondary_school_curriculum]})
    (end-act {@self enrol_secondary})
    (end-goal {@self enrol_secondary})))

; ----- university ----------------------------------------------------------
(npc-act enrol_university_act
  (when (believes {@self enrol_university}))
  (duration 60)
  (act-effects
    ; The SUBJECT is interest-led (the class gate decided WHETHER you attend;
    ; interest decides WHAT you read), falling back to a random discipline.
    ; The primary / secondary curricula are tiers, not disciplines - excluded.
    (bind (random-held-kind-target interest [k academic_field]
                                   [k primary_school_curriculum]
                                   [k secondary_school_curriculum]) ?led)
    (if (is-kind ?led)
        (begin-belief {@self study ?led})
        (do
          (bind (random-subkind [k academic_field]
                                [k primary_school_curriculum]
                                [k secondary_school_curriculum]) ?subject)
          (if (is-kind ?subject)
              (begin-belief {@self study ?subject}))))
    (end-act {@self enrol_university})
    (end-goal {@self enrol_university})))
