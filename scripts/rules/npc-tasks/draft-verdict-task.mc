; ----------------------------------------------------------------------------
; draft-verdict ?p ?job - answer ONE applicant about ONE seat: pen, fill, envelope, post
; from the OFFICE out-box; for an offer, pencil the promise on the wage book. Which
; verdict it is, the SEAT decides: open, an offer; held, a rejection.
;
; The seat travels by its anchors - the org's name and the line - on the notice, the form
; and the letter alike, so every mind that reads any of them lands on the same object. An
; offer carries the whole description of the seat as well: its level, its salary and its
; shift, so the man who reads it holds the job fully decorated before he walks in, and the
; officer's word at the counter has only to make it his.
;
; The letter this task pens is the one it CREATED: the CREATE postlude stashes it under the
; running task's own `letter` key, so a restart re-reads that key instead of penning a
; second one. Each later stage reads the world for what is already done. The out-box is
; located by the sibling try once the letter is addressed and no pile is known.
; ----------------------------------------------------------------------------

(npc-task {@self draft-verdict ?p ?job}:?dv-rel
  (aspect labour)
  (track-skill-level [k law])
  (tar human)
  (aux [k job])
  (and
    (sequence
      (role ?org {@self duty-to ?org recruit-staff})
      (role ?wp {?org workplace ?wp})

      ; THE VERDICT is the seat's state at the moment the pen is picked up, and it is the
      ; letter's kind from then on: a restart reads the kind off the letter already begun.
      (stage
        (effects
          (if (bb-any ?dv-rel letter)
              (then (bind (bb-read ?dv-rel letter) ?ltr)
                    (bind (kind ?ltr) ?kind))
              (else (bind (if -{? job ?job}
                              (then [k offer-letter])
                              (else [k rejection-letter]))
                          ?kind)
                    (maintain-proposal {@self CREATE-ENTITY ?kind}:?ce
                      [/postlude (bind (bb-read ?ce created) ?ltr)
                                 (bb-write ?dv-rel letter ?ltr)])))))

      ; THE PAGE. Both letters name the seat by its anchors. The offer adds the seat's
      ; description: a new man is taken on at the entry level, at that level's pay, on the
      ; shift the ledger line was established with.
      (stage
        (role ?reg {?org employee-register ?reg})
        (when {?p name ?rname}
              {?p home ?rhome}
              {?rhome address ?raddress}
              {?job job-id ?line}
              {?org name ?org-name}
              (kind ?job): ?jk
              (table-match (attr ?reg writing) job-id ?line shift ?shift)
              (table-match income_by_level level [k trainee] income ?salary))
        (effects
          (if (unsubstantial (attr ?ltr writing))
              (then
                (if (= ?kind [k offer-letter])
                    (then (maintain-proposal
                            {@self write-doc ?ltr (table-msg [/addressee ?rname /address ?raddress]
                                                         [[applicant ?rname] [job-kind ?jk]
                                                          [org-name ?org-name] [job-id ?line]
                                                          [level [k trainee]] [salary ?salary]
                                                          [shift ?shift]])}))
                    (else (maintain-proposal
                            {@self write-doc ?ltr (table-msg [/addressee ?rname /address ?raddress]
                                                         [[applicant ?rname] [job-kind ?jk]
                                                          [org-name ?org-name] [job-id ?line]])})))))))

      (stage
        (role ?out [k outgoing-mail-stack] (spatial ?out building ?wp))
        (effects (maintain-proposal {@self send-mail ?ltr ?out})))

      ; An OFFER goes in the book as well as the post: the officer walks to the wage book
      ; and pencils the man's name against the line. A rejection leaves no mark - nothing
      ; was promised.
      (stage
        (role @self {?org employee-register ?reg})
        (effects
          (if (and (= ?kind [k offer-letter])
                   (not (spatial ?reg co-located @self)))
              (then (maintain-proposal {@self go (spatial ?reg space)})))))
      (stage
        (role @self {?org employee-register ?reg})
        (when {?p name ?rname}
              {?job job-id ?line})
        (effects
          (if (= ?kind [k offer-letter])
              (then (maintain-proposal {@self RECORD-OFFER ?rname ?line})))))

      ; The promise is a state of the SEAT, held at both ends: the man learns it off the
      ; letter, the officer holds it from the moment it is pencilled. An acceptance spends
      ; it; until then the seat is offered to nobody else.
      (stage
        (effects
          (if (and (= ?kind [k offer-letter]) -{?job offered-to ?p})
              (then (begin-belief {?job offered-to ?p})))
          (bb-clear ?dv-rel letter)
          (set-outcome ?dv-rel /succ))))

    (try
      (role ?org {@self duty-to ?org recruit-staff})
      (role ?wp {?org workplace ?wp})
      (role ?held [k letter] (spatial ?held held-by @self)
                             (substantial (attr ?held destination)))
      (no-role [k outgoing-mail-stack])
      (effects (maintain-proposal {@self locate [k outgoing-mail-stack] ?wp})))))
