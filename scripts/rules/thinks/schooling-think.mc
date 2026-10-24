; --- leave-primary: every primary pupil finishes at ~11 ----------------------
(think leave-primary
  (cooldown 1 m try-once)
  (rng-stream behaviour)

  ; Deterministic: @self, a primary pupil who has reached the leaving age, takes
  ; the basic-schooling credential (graduate-from-study mints its school-grades
  ; and ends the study). The credential then gates secondary
  ; enrollment; a non-continuer becomes apprenticeship-eligible. Monthly firing is
  ; idempotent - the first fire ends the study, so later months no-op. age -> (when).
  (role @self {@self age ?age}
              {@self study [k primary-school-curriculum]}

    (when (>= ?age 11))

    (effects
      (graduate-from-study)
      )))

; --- leave-secondary: a secondary pupil finishes at ~17 ----------------------
(think leave-secondary
  (cooldown 1 m try-once)
  (rng-stream behaviour)

  (role @self {@self age ?age}
              {@self study [k secondary-school-curriculum]}

    (when (>= ?age 17))

    (effects
      (graduate-from-study)
      )))

; --- graduate-university: a degree is taken at ~22 ---------------------------
(think graduate-university
  (cooldown 1 m try-once)
  (rng-stream behaviour)

  ; Any ongoing study at 22+ is a university degree (primary / secondary pupils
  ; are <18 and have already left). graduate-from-study mints the subject credential
  ; {@self school-grades <subject> <grade>} and an interest in the subject.
  (role @self {@self age ?age}
              {@self study ?}

    (when (>= ?age 22))

    (effects
      (graduate-from-study)
      )))
