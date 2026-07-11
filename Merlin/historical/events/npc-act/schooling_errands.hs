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
(npc-think primary_go
  (short-term-think)
  (goal {@self enrol_primary})
  ; The school is role-cast from the schools the NPC KNOWS; nearest preferred,
  ; weighted. No known school -> no fire (the goal waits). Replaces (venue ...).
  (role ?go_dest [k building school] (select (score (near @self ?go_dest)) (policy roulette)))
  (when (not (at-place-kind [k building school])))
  (utility 35)
  (cont-fire-effects (go-into ?go_dest)))
(npc-think primary_dwell
  (short-term-think)
  (goal {@self enrol_primary})
  (when (at-place-kind [k building school]))
  (utility 35)
  (cont-fire-effects (begin-goal {@self enrol_primary})))
(npc-act enrol_primary_act
  (when (believes {@self enrol_primary}))
  (duration 60)
  (act-effects
    (begin-belief {@self study [k primary_school_curriculum]})
    (end-act {@self enrol_primary})
    (end-goal {@self enrol_primary})))

; ----- secondary -----------------------------------------------------------
(npc-think secondary_go
  (short-term-think)
  (goal {@self enrol_secondary})
  (role ?go_dest [k building school] (select (score (near @self ?go_dest)) (policy roulette)))
  (when (not (at-place-kind [k building school])))
  (utility 35)
  (cont-fire-effects (go-into ?go_dest)))
(npc-think secondary_dwell
  (short-term-think)
  (goal {@self enrol_secondary})
  (when (at-place-kind [k building school]))
  (utility 35)
  (cont-fire-effects (begin-goal {@self enrol_secondary})))
(npc-act enrol_secondary_act
  (when (believes {@self enrol_secondary}))
  (duration 60)
  (act-effects
    (begin-belief {@self study [k secondary_school_curriculum]})
    (end-act {@self enrol_secondary})
    (end-goal {@self enrol_secondary})))

; ----- university ----------------------------------------------------------
(npc-think university_go
  (short-term-think)
  (goal {@self enrol_university})
  (role ?go_dest [k building school] (select (score (near @self ?go_dest)) (policy roulette)))
  (when (not (at-place-kind [k building school])))
  (utility 35)
  (cont-fire-effects (go-into ?go_dest)))
(npc-think university_dwell
  (short-term-think)
  (goal {@self enrol_university})
  (when (at-place-kind [k building school]))
  (utility 35)
  (cont-fire-effects (begin-goal {@self enrol_university})))
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
