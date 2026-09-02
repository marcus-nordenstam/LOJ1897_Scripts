; ----------------------------------------------------------------------------
; matriculate ?curriculum - the DOING of enrolling in a school: walk to a school I
; know and record my course of study there (mint {@self study ?curriculum}). One task
; for every tier - the decisions (schooling_think enroll_primary / _secondary /
; _university) propose it and own its life (the role-completion drops when {@self study}
; is minted). A school TIER (primary / secondary curriculum) is recorded as-is; a
; UNIVERSITY reading (the broad [k academic-field] intent) picks a specific interest-led
; discipline at matriculation, falling back to any discipline. Minting the study belief
; is the doing; no env write, so no act - a simple thinking task mints the belief.
; ----------------------------------------------------------------------------

(npc-task {@self matriculate ?curriculum}:?mt-rel
  (tar academic-field)
  (and
    ; GO: not at a school -> travel to one I know (nearest preferred).
    (try
      (role ?go_dest [k building school]
            (select (score (near @self ?go_dest)) (policy roulette)))
      (when (not (is-a (spatial @self building) [k building school])))
      (effects (maintain-proposal {@self enter ?go_dest})))

    ; MATRICULATE: at a school -> record my study. Minting {@self study ...} trips the
    ; decision's completion role, which withdraws the task.
    (try
      (when (is-a (spatial @self building) [k building school]))
      (effects
        (if (is-a ?curriculum [k academic-field])
          (then
            ; university: an interest-led discipline (the tiers are not disciplines), else any.
            (if (is-kind (random-held-kind-target interest [k academic-field]
                                                  [k primary-school-curriculum] [k secondary-school-curriculum]))
                (then (random-held-kind-target interest [k academic-field]
                                                [k primary-school-curriculum] [k secondary-school-curriculum]): ?led
                      (begin-belief {@self study ?led}))
                (else (if (is-kind (random-subkind [k academic-field]
                                                   [k primary-school-curriculum] [k secondary-school-curriculum]))
                          (then (random-subkind [k academic-field]
                                                [k primary-school-curriculum] [k secondary-school-curriculum]): ?sub
                                (begin-belief {@self study ?sub}))))))
          (else (begin-belief {@self study ?curriculum})))))))
