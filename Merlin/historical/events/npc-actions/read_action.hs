; ----------------------------------------------------------------------------
; read - THE document-reading action (one physical effect: eyes on paper; the
; words become the reader's beliefs). One body, per-document-kind arms:
;
;   job_description  - the parish-board advert: its record fields internalize
;                      as advert_* beliefs ON the advert object (what a seeker
;                      needs to choose and apply - job, pay, rank, eligibility,
;                      the workplace and the org's articles).
;   letter           - the writing's composed message adopts through the shared
;                      letter codec ((read-writing ?doc) - offer / rejection /
;                      any letter kind; dedup'd by {@self read <letter>}).
;   employee_register- the reader looks himself up on the wage book: his own
;                      row (if any) becomes {@self enrolled <job> /aux <level>},
;                      the employment_realized trigger.
; ----------------------------------------------------------------------------

(npc-action {@self read ?doc}
  (duration 10)
  (effects
    (if (is-a ?doc [k job_description])
        (then
          (read-doc-record [k job_description] ?doc
              (org_record ?art) (job ?jk) (level ?lvl) (salary ?sal)
              (class_floor ?cf) (workplace ?wp))
          (begin-belief {?doc advert_org ?art})
          (begin-belief {?doc advert_job ?jk})
          (begin-belief {?doc advert_level ?lvl})
          (begin-belief {?doc advert_pay ?sal})
          (begin-belief {?doc advert_floor ?cf})
          (begin-belief {?doc advert_workplace ?wp})))
    (if (is-a ?doc [k letter])
        (then (read-writing ?doc)))
    (if (is-a ?doc [k employee_register])
        (then
          (if (read-doc-record [k employee_register] ?doc
                  (find worker @self) (job ?myjk) (level ?mylvl))
              (then (begin-belief {@self enrolled ?myjk ?mylvl})))))
    (set-outcome {@self read ?doc} succ)))
