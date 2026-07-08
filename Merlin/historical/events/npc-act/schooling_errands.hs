; ----------------------------------------------------------------------------
; schooling_errands - the npc-ACT halves of the schooling-enrolment splits (Item 5).
;
; Each enrolment decision (schooling.hs enroll_primary / _secondary / _university)
; minted {@self goal {@self enrol_<level>}}. The pupil walks to a school (or up to
; the university) and matriculates there - co-presence at the school instead of a
; faceless credential edit. Three level-specific lanes (the curriculum differs at
; commit); each shares the go/dwell/commit shape. Arrival is gated on the building
; KIND ((venue ...) random-picks per call). Low utility (35): schooling yields to
; work / rest, a child's errand of the day.
; ----------------------------------------------------------------------------

; ----- primary -------------------------------------------------------------
(hsim-npc-behaviour primary_go
  (short-term-think)
  (when (and (has-goal enrol_primary) (not (at-place-kind [k building school]))))
  (utility 35)
  (effects (bind (venue [k building school]) ?go_dest) (begin-act {@self go ?go_dest})))
(hsim-npc-behaviour primary_dwell
  (short-term-think)
  (when (and (has-goal enrol_primary) (at-place-kind [k building school])))
  (utility 35)
  (effects (begin-act {@self enrol_primary} 60 primary_commit)))
(hsim-npc-behaviour primary_commit
  (on-completion)
  (effects
    (begin-belief {@self study [k primary_school_curriculum]})
    (end-goal {@self enrol_primary})
    ))

; ----- secondary -----------------------------------------------------------
(hsim-npc-behaviour secondary_go
  (short-term-think)
  (when (and (has-goal enrol_secondary) (not (at-place-kind [k building school]))))
  (utility 35)
  (effects (bind (venue [k building school]) ?go_dest) (begin-act {@self go ?go_dest})))
(hsim-npc-behaviour secondary_dwell
  (short-term-think)
  (when (and (has-goal enrol_secondary) (at-place-kind [k building school])))
  (utility 35)
  (effects (begin-act {@self enrol_secondary} 60 secondary_commit)))
(hsim-npc-behaviour secondary_commit
  (on-completion)
  (effects
    (begin-belief {@self study [k secondary_school_curriculum]})
    (end-goal {@self enrol_secondary})
    ))

; ----- university ----------------------------------------------------------
(hsim-npc-behaviour university_go
  (short-term-think)
  (when (and (has-goal enrol_university) (not (at-place-kind [k building school]))))
  (utility 35)
  (effects (bind (venue [k building school]) ?go_dest) (begin-act {@self go ?go_dest})))
(hsim-npc-behaviour university_dwell
  (short-term-think)
  (when (and (has-goal enrol_university) (at-place-kind [k building school])))
  (utility 35)
  (effects (begin-act {@self enrol_university} 60 university_commit)))
(hsim-npc-behaviour university_commit
  (on-completion)
  (effects
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
    (end-goal {@self enrol_university})
    ))
