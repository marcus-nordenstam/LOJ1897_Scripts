; ----------------------------------------------------------------------------
; matriculate ?curriculum - the DOING of enrolling in a school: walk to a school building
; whose school (the org working there) I know, and record my course of study at that
; school (mint {@self study ?curriculum ?school-org}). One task
; for every tier - the decisions (schooling_think enroll-primary / _secondary /
; _university) propose it and own its life (the role-completion drops when {@self study}
; is minted). A school TIER (primary / secondary curriculum) is recorded as-is; a
; UNIVERSITY reading (the broad [k academic-field] intent) picks a specific interest-led
; discipline at matriculation, falling back to any discipline. Minting the study belief
; is the doing; no env write, so no act - a simple thinking task mints the belief.
; ----------------------------------------------------------------------------

(task {@self matriculate ?curriculum}:?matriculate
  (tar [k academic-field])
  (and
    ; GO: not at a school -> travel to one I know whose school I know (nearest preferred).
    (try
      (role ?go_dest [k school]
            (select (score (near @self ?go_dest)) (policy roulette unknown-last))
        (role ?academy {?academy workplace ?go_dest}
          (when (not (is-a (spatial @self building) [k school])))
          (effects (maintain-proposal {@self go-to ?go_dest})))))

    ; MATRICULATE: at a school -> record my study there, at its school. Minting {@self study ...}
    ; trips the decision's completion role, which withdraws the task. A school tier is recorded
    ; as-is.
    (try
      (role ?school [k school] (spatial @self building ?school)
        (role ?academy {?academy workplace ?school}
          (when (or (is-a ?curriculum [k primary-school-curriculum])
                    (is-a ?curriculum [k secondary-school-curriculum])))
          (effects
            (begin-belief {@self study ?curriculum ?academy})
            (set-outcome ?matriculate /succ)))))
    ; A university reading: an interest-led discipline (the tiers are not disciplines), else any.
    (try
      (role ?school [k school] (spatial @self building ?school)
        (role ?academy {?academy workplace ?school}
          (when (and (not (is-a ?curriculum [k primary-school-curriculum]))
                     (not (is-a ?curriculum [k secondary-school-curriculum]))))
          (effects
            (tolerate (random-held-kind-target interest [k academic-field]
                                               [k primary-school-curriculum] [k secondary-school-curriculum])): ?led
            (begin-belief {@self study (flip (is-kind ?led)
                                             ?led
                                             (random-subkind [k academic-field]
                                                             [k primary-school-curriculum] [k secondary-school-curriculum]))
                                       ?academy})
            (set-outcome ?matriculate /succ)))))))
