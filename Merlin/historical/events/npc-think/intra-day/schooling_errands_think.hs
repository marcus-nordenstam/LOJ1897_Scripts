; ----------------------------------------------------------------------------
; schooling_errands (npc-think) - the go/dwell halves of the schooling-enrolment
; splits.
;
; Each enrolment decision (schooling.hs enroll_primary / _secondary / _university)
; minted {@self goal {@self enrol_<level>}}. The pupil walks to a school (or up to
; the university) and matriculates there - co-presence at the school instead of a
; faceless credential edit. Three level-specific lanes; each shares the go/dwell
; shape. Arrival is gated on the building KIND. Low utility (35): schooling yields
; to work / rest, a child's errand of the day. The matriculation completions
; (enrol_<level>_act) live in npc-act/schooling_errands.hs.
; ----------------------------------------------------------------------------

; ----- primary -------------------------------------------------------------
(npc-think primary_go
  (schedule on-commit)
  (if-blocked hold)
  (goal {@self enrol_primary})
  ; The school is role-cast from the schools the NPC KNOWS; nearest preferred,
  ; weighted. No known school -> no fire (the goal waits). Replaces (venue ...).
  (role ?go_dest [k building school] (select (score (near @self ?go_dest)) (policy roulette)))
  (when (not (at-place-kind [k building school])))
  (utility 35)
  (effects       (begin-goal {@self enter ?go_dest}))
  (cease-effects (end-goal   {@self enter ?go_dest})))
(npc-think primary_dwell
  (short-term-think)
  (goal {@self enrol_primary})
  (when (at-place-kind [k building school]))
  (utility 35)
  (cont-fire-effects (begin-goal {@self enrol_primary})))

; ----- secondary -----------------------------------------------------------
(npc-think secondary_go
  (schedule on-commit)
  (if-blocked hold)
  (goal {@self enrol_secondary})
  (role ?go_dest [k building school] (select (score (near @self ?go_dest)) (policy roulette)))
  (when (not (at-place-kind [k building school])))
  (utility 35)
  (effects       (begin-goal {@self enter ?go_dest}))
  (cease-effects (end-goal   {@self enter ?go_dest})))
(npc-think secondary_dwell
  (short-term-think)
  (goal {@self enrol_secondary})
  (when (at-place-kind [k building school]))
  (utility 35)
  (cont-fire-effects (begin-goal {@self enrol_secondary})))

; ----- university ----------------------------------------------------------
(npc-think university_go
  (schedule on-commit)
  (if-blocked hold)
  (goal {@self enrol_university})
  (role ?go_dest [k building school] (select (score (near @self ?go_dest)) (policy roulette)))
  (when (not (at-place-kind [k building school])))
  (utility 35)
  (effects       (begin-goal {@self enter ?go_dest}))
  (cease-effects (end-goal   {@self enter ?go_dest})))
(npc-think university_dwell
  (short-term-think)
  (goal {@self enrol_university})
  (when (at-place-kind [k building school]))
  (utility 35)
  (cont-fire-effects (begin-goal {@self enrol_university})))
