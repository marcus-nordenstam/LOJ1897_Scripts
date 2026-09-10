; ----------------------------------------------------------------------------
; draft-verdict ?applicant ?kind - answer ONE applicant (whom @self learned of by
; READing their application) with a verdict letter of ?kind (offer-letter /
; rejection-letter): pen, fill, envelope, post from the OFFICE out-box, then end the
; applicant's apply-for belief (answered - don't re-draft). The letter this task pens is
; the one it CREATED: the CREATE postlude stashes it under the running task's own
; `letter` key, so a restart re-reads that key instead of picking up whatever letter
; happens to be in hand. Each later stage reads the letter for what is already done, so a
; restarted round never pens a second one. The out-box is located by the sibling try once
; the letter is addressed and no pile is known; the send stage holds until one is. WHICH
; verdict is the proposing resolve-applications round's decision, not this task's.
; ----------------------------------------------------------------------------

(npc-task {@self draft-verdict ?applicant ?kind}:?dv-rel
  (track-skill-level [k law])
  (tar human)
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

      ; The letter NAMES THE POST. A verdict that says only "yes" leaves the reader to guess
      ; which of his applications it answers - and the moment he has two in flight there is
      ; no guessing it right. Kind + org is what makes it THAT seat to him, resolved against
      ; his own objects; he already knows where the org keeps its door.
      (stage
        (when {?applicant name ?rname}
              {?org name ?org-name}
              (any {?applicant apply-for ?}): ?af-rel
              (bind ?af-rel.target ?jk)
              (substantial ?jk))
        (effects
          (if (unsubstantial (attr ?ltr writing))
              (then (maintain-proposal
                      {@self WRITE ?ltr (table-msg [[applicant ?rname] [job-kind ?jk]
                                                    [org-name ?org-name]])})))))

      (stage
        (when {?applicant address ?raddress})
        (effects
          (if (unsubstantial (attr ?ltr destination))
              (then (maintain-proposal {@self ADDRESS ?ltr ?raddress})))))

      (stage
        (role ?out [k outgoing-mail-stack] (spatial ?out building ?wp))
        (effects (maintain-proposal {@self send-mail ?ltr ?out})))

      (stage
        (effects
          (bb-clear ?dv-rel letter)
          (end-belief {?applicant apply-for ?})
          (set-outcome ?dv-rel /succ))))

    (try
      (role ?org {@self duty-to ?org recruit-staff})
      (role ?wp {?org workplace ?wp})
      (role ?held [k letter] (spatial ?held held-by @self)
                             (substantial (attr ?held destination)))
      (no-role [k outgoing-mail-stack])
      (effects (maintain-proposal {@self locate [k outgoing-mail-stack] ?wp})))))
