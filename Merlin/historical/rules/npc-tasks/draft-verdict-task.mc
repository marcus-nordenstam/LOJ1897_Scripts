; ----------------------------------------------------------------------------
; draft-verdict ?p ?kind - answer ONE applicant with a verdict letter of ?kind
; (offer-letter / rejection-letter): pen, fill, envelope, post from the OFFICE out-box;
; for an offer, pencil the promise on the wage book; then burn the form he wrote. WHICH
; verdict is the proposing recruit-staff rung's decision, not this task's.
;
; It answers a MAN, by way of the paper he wrote. Everything the letter needs - his name,
; the post he asked for, where to send it - @self holds about HIM, read off the form; the
; form itself is reached through {?app written-by ?p}. Targeting the man is what lets this
; task burn the form as its own last stage: a task that targeted the form would conclude
; itself, with a fail, by destroying it.
;
; The letter this task pens is the one it CREATED: the CREATE postlude stashes it under the
; running task's own `letter` key, so a restart re-reads that key instead of penning a
; second one. Each later stage reads the world for what is already done. The out-box is
; located by the sibling try once the letter is addressed and no pile is known.
; ----------------------------------------------------------------------------

(npc-task {@self draft-verdict ?p ?kind}:?dv-rel
  (aspect labour)
  (track-skill-level [k law])
  (tar human)
  (aux ?)
  (and
    (sequence
      (role ?org {@self duty-to ?org recruit-staff})
      (role ?wp {?org workplace ?wp})

      (stage
        (effects
          (if (bb-any ?dv-rel letter)
              (then (bind (bb-read ?dv-rel letter) ?ltr))
              (else (maintain-proposal {@self CREATE-ENTITY ?kind}:?ce
                      [/postlude (bind (bb-read ?ce created) ?ltr)
                                 (bb-write ?dv-rel letter ?ltr)])))))

      ; The letter NAMES THE SEAT: its kind, the org's name and the line are what make it
      ; THAT seat to the reader, resolved against his own objects; he already knows where
      ; the org keeps its door.
      (stage
        (when {?p name ?rname}
              {?p home ?rhome}
              {?rhome address ?raddress}
              {?p apply-for ?job /succ}
              {?job job-id ?line}
              {?org name ?org-name}
              (kind ?job): ?jk)
        (effects
          (if (unsubstantial (attr ?ltr writing))
              (then (maintain-proposal
                      {@self WRITE ?ltr (table-msg [/addressee ?rname /address ?raddress]
                                                   [[applicant ?rname] [job-kind ?jk]
                                                    [org-name ?org-name] [job-id ?line]])})))))

      (stage
        (role ?out [k outgoing-mail-stack] (spatial ?out building ?wp))
        (effects (maintain-proposal {@self send-mail ?ltr ?out})))

      ; An OFFER goes in the book as well as the post: the officer walks to the wage book
      ; and pencils the man's name against a vacant line of his kind. A rejection leaves
      ; no mark - nothing was promised.
      (stage
        (role ?reg {?org employee-register ?reg})
        (effects
          (if (and (= ?kind [k offer-letter])
                   (not (spatial ?reg co-located @self)))
              (then (maintain-proposal {@self go (spatial ?reg space)})))))
      (stage
        (role ?reg {?org employee-register ?reg})
        (when {?p name ?rname}
              {?p apply-for ?job /succ}
              {?job job-id ?line})
        (effects
          (if (= ?kind [k offer-letter])
              (then (maintain-proposal {@self RECORD-OFFER ?rname ?line})))))

      (stage
        (effects
          (bb-clear ?dv-rel letter)
          (set-outcome ?dv-rel /succ))))

    (try
      (role ?org {@self duty-to ?org recruit-staff})
      (role ?wp {?org workplace ?wp})
      (role ?held [k letter] (spatial ?held held-by @self)
                             (substantial (attr ?held destination)))
      (no-role [k outgoing-mail-stack])
      (effects (maintain-proposal {@self locate [k outgoing-mail-stack] ?wp})))))
