; ----------------------------------------------------------------------------
; post-ad ?org ?job - put a notice up on the parish board for ONE open post. The post
; is the parameter, so the notice knows what it advertises: the role is the post
; object's OWN kind, not a lookup in a staffing table the officer has no way of
; knowing, and an org with two distinct openings posts two distinct notices.
;
; The notice is the WHOLE sentence the org holds ({?org display-ad ?job} plus where to
; apply), so a seeker who READs the board adopts the org's own fact. One sequence at a
; known church: go there, pen the sheet, write the notice, remember it stands. The
; sibling try searches for a church while none is known. The sheet it writes on is the
; one it CREATED, kept under the running task's own key, so a restarted posting re-reads
; that key instead of penning a second sheet.
; ----------------------------------------------------------------------------

(npc-task {@self post-ad ?org ?job}:?pad-rel
  (tar org)
  (aux job)
  (and
    (sequence
      (role ?board [k building church] (select (score (near @self ?board)) (policy roulette)))

      (stage
        (effects
          (if (not (spatial @self building ?board))
              (then (maintain-proposal {@self enter ?board})))))

      (stage
        (effects
          (if (bb-any ?pad-rel ad)
              (then (bind (bb-read ?pad-rel ad) ?ad))
              (else (maintain-proposal {@self CREATE-ENTITY [k job-posting]}:?ce
                      [/postlude (bind (bb-read ?ce created) ?ad)
                                 (bb-write ?pad-rel ad ?ad)])))))

      ; The notice is a FORM: the job's kind, the org by name, the org's own reference for
      ; the seat, and where to present oneself - the book's own room, as its civic address
      ; (the house and the room in one value).
      ;
      ; The JOB-ID is what makes the notice name a SEAT rather than a kind of work. Without
      ; it a reader learns only `a clerk's place at companies-house`, which two separate
      ; vacancies answer equally - so he cannot tell one from the other, cannot tell a
      ; second telling of one vacancy from a first telling of two, and the post he is
      ; offered is never quite the post he read about. It is the org's reference, not its
      ; bookkeeping: a real advertisement quotes one.
      (stage
        (role ?reg {?org employee-register ?reg})
        (when {?org name ?org-name}
              {?job job-id ?job-id}
              (kind ?job): ?jk
              (spatial ?reg space): ?office
              (address ?office): ?apply-at
              (substantial ?apply-at))
        (effects
          (if (unsubstantial (attr ?ad writing))
              (then (maintain-proposal
                      {@self WRITE ?ad (table-msg [[job-kind ?jk] [org-name ?org-name] [job-id ?job-id] [apply-at ?apply-at]])})))))

      (stage
        (effects
          (begin-belief {?org display-ad ?job})
          (bb-clear ?pad-rel ad)
          (set-outcome ?pad-rel /succ))))

    (try
      (no-role [k building church])
      (when (and -{@self find-building [k building church] ? /fail}
                 (current-region @self): ?rg))
      (effects (maintain-proposal {@self find-building [k building church] ?rg})))))
