; ----------------------------------------------------------------------------
; draft-verdict ?app ?kind - answer ONE application FORM with a verdict letter of ?kind
; (offer-letter / rejection-letter): pen, fill, envelope, post from the OFFICE out-box,
; then destroy the form. WHICH verdict is the proposing resolve-applications round's
; decision, not this task's.
;
; It answers the PAPER, never a person. Everything the letter needs - whom to name, which
; post, where to send it - is written on the form in hand, so @self need believe nothing
; about a man he has not met. Destroying the form is what takes him off the queue: a
; clerk's out-tray is his record of what is done.
;
; The letter this task pens is the one it CREATED: the CREATE postlude stashes it under
; the running task's own `letter` key, so a restart re-reads that key instead of picking
; up whatever letter happens to be in hand. Each later stage reads the letter for what is
; already done, so a restarted round never pens a second one. The out-box is located by
; the sibling try once the letter is addressed and no pile is known; the send stage holds
; until one is.
; ----------------------------------------------------------------------------

(npc-task {@self draft-verdict ?app ?kind}:?dv-rel
  (track-skill-level [k law])
  (tar application)
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
        (when (and (table-match (attr ?app writing) field applicant value ?rname)
                   (table-match (attr ?app writing) field job value ?jk))
              {?org name ?org-name})
        (effects
          (if (unsubstantial (attr ?ltr writing))
              (then (maintain-proposal
                      {@self WRITE ?ltr (table-msg [[applicant ?rname] [job-kind ?jk]
                                                    [org-name ?org-name]])})))))

      (stage
        (when (table-match (attr ?app writing) field home value ?raddress))
        (effects
          (if (unsubstantial (attr ?ltr destination))
              (then (maintain-proposal {@self ADDRESS ?ltr ?raddress})))))

      (stage
        (role ?out [k outgoing-mail-stack] (spatial ?out building ?wp))
        (effects (maintain-proposal {@self send-mail ?ltr ?out})))

      ; The answer is in the post, so the form has done its work. Its own stage: the
      ; destroy must CONCLUDE before the task does, or the paper stays in hand and the
      ; round re-drafts the verdict it has already sent.
      (stage
        (effects (maintain-proposal {@self DESTROY-ENTITY ?app})))

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
