; ----------------------------------------------------------------------------
; draft-verdict ?app ?kind - answer ONE application FORM with a verdict letter of ?kind
; (offer-letter / rejection-letter): pen, fill, envelope, post from the OFFICE out-box.
; WHICH verdict is the proposing resolve-applications round's decision, not this task's.
;
; It answers a MAN, by way of the paper he wrote. Everything the letter needs - whom to
; name, which post, where to send it - @self read off the form and now holds about HIM: his
; name, the apply-for he completed, and the home he gave. The form is reached through
; {?app written-by ?rman}. BURNING the answered form is what takes him off the queue, and
; that is a recruit-staff rung: this task targets the form, so realizing it destroyed would
; conclude the very task that answered it, with a fail.
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
        (when {?app written-by ?rman}
              {?rman name ?rname}
              {?rman apply-for ?jk ? /succ}
              {?org name ?org-name})
        (effects
          (if (unsubstantial (attr ?ltr writing))
              (then (maintain-proposal
                      {@self WRITE ?ltr (table-msg [[applicant ?rname] [job-kind ?jk]
                                                    [org-name ?org-name]])})))))

      (stage
        (when {?app written-by ?rman}
              {?rman home ?rhome}
              {?rhome address ?raddress})
        (effects
          (if (unsubstantial (attr ?ltr destination))
              (then (maintain-proposal {@self ADDRESS ?ltr ?raddress})))))

      (stage
        (role ?out [k outgoing-mail-stack] (spatial ?out building ?wp))
        (effects (maintain-proposal {@self send-mail ?ltr ?out})))

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
