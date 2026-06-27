; ----------------------------------------------------------------------------
; orient_errand - the npc-ACT half of new_job_orientation.
;
; @self holds {@self goal {@self orient}}. He routes to the parish church (the
; common civic space) and, once there, reads the PUBLIC register of incorporations:
; for every articles_of_incorporation document he forms / recalls its org object and
; mints the kind / founder / record beliefs that let the belief-pure casting events
; role over it. (documents [k ...]) is a public-register read in an act effect (not
; a role filter), so it stays off the per-candidate cache path; the minted beliefs
; are mental writes, safe inside the document walk (no entity create / destroy).
;
;   orient_go    : hold the goal, not at a church -> travel to one.
;   orient_dwell : hold the goal, at a church -> a short dwell (reading the register).
;   orient_read  : completion - read the register + clear the goal.
; ----------------------------------------------------------------------------

(hsim-event orient_go
  (intra-day)
  (when (and (has-goal orient)
             (not (at-place-kind [k building church]))))
  (utility 28)
  (effects (go @self (venue [k building church]))))

(hsim-event orient_dwell
  (intra-day)
  (when (and (has-goal orient)
             (at-place-kind [k building church])))
  (utility 28)
  (effects (act orient_read 30)))

(hsim-event orient_read
  (schedule (completion-only))
  (effects
    ; Read the public register: per articles document, form / recall its org object
    ; and mint the queryable beliefs the casting filters read. ?ok = org kind,
    ; ?f = founder (both off the articles writing); ?org = the formed mental object.
    (for-each ?art (documents [k articles_of_incorporation])
      (do
        (read-doc-record [k articles_of_incorporation] ?art (kind ?ok) (founder ?f))
        (imagine-or-recall ?ok {?art declares_org ?org})
        (begin-belief {?org isa ?ok})
        (begin-belief {?org record ?art})
        (begin-belief {?org founder ?f})))
    (clear-goal @self orient)))
