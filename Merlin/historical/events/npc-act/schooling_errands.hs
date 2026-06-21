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
(hsim-event primary_go
  (intra-day) (nl "@self sets off for school")
  (when (and (has-goal enrol_primary) (not (self-at [k building school]))))
  (utility 35)
  (effects (go @self (venue [k building school]))))
(hsim-event primary_dwell
  (intra-day) (nl "@self is enrolled at school")
  (when (and (has-goal enrol_primary) (self-at [k building school])))
  (utility 35)
  (effects (act primary_commit 60)))
(hsim-event primary_commit
  (schedule (completion-only)) (nl "@self starts primary school")
  (effects
    (enroll @self primary_school_curriculum)
    (clear-goal @self enrol_primary)
    (log _education @self)))

; ----- secondary -----------------------------------------------------------
(hsim-event secondary_go
  (intra-day) (nl "@self sets off for school")
  (when (and (has-goal enrol_secondary) (not (self-at [k building school]))))
  (utility 35)
  (effects (go @self (venue [k building school]))))
(hsim-event secondary_dwell
  (intra-day) (nl "@self is enrolled at school")
  (when (and (has-goal enrol_secondary) (self-at [k building school])))
  (utility 35)
  (effects (act secondary_commit 60)))
(hsim-event secondary_commit
  (schedule (completion-only)) (nl "@self goes on to secondary school")
  (effects
    (enroll @self secondary_school_curriculum)
    (clear-goal @self enrol_secondary)
    (log _education @self)))

; ----- university ----------------------------------------------------------
(hsim-event university_go
  (intra-day) (nl "@self sets off for university")
  (when (and (has-goal enrol_university) (not (self-at [k building school]))))
  (utility 35)
  (effects (go @self (venue [k building school]))))
(hsim-event university_dwell
  (intra-day) (nl "@self matriculates")
  (when (and (has-goal enrol_university) (self-at [k building school])))
  (utility 35)
  (effects (act university_commit 60)))
(hsim-event university_commit
  (schedule (completion-only)) (nl "@self goes up to university")
  (effects
    (enroll-university @self)
    (clear-goal @self enrol_university)
    (log _education @self)))
