; ----------------------------------------------------------------------------
; draft-verdict ?applicant ?kind - answer ONE applicant (whom @self learned of by
; READing their application) with a verdict letter of ?kind (offer-letter /
; rejection-letter): pen, fill, envelope, post from the OFFICE out-box, then end the
; applicant's apply-for belief (answered - don't re-draft). Each stage reads the letter
; in hand for what is already done, so a restarted round never pens a second one. The
; out-box is located by the sibling try once the letter is addressed and no pile is
; known; the send stage holds until one is. WHICH verdict is the proposing
; resolve-applications round's decision, not this task's.
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
          (if (empty (spatial @self hold ?kind))
              (then (maintain-proposal {@self CREATE-ENTITY ?kind}:?ce
                      [/postlude (bind (bb-read ?ce created) ?ltr)]))
              (else (bind (head (spatial @self hold ?kind)) ?ltr)))))

      (stage
        (when {?applicant name ?rname})
        (effects
          (if (unsubstantial (attr ?ltr writing))
              (then (maintain-proposal {@self WRITE ?ltr [[applicant ?rname]]})))))

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
          (end-belief {?applicant apply-for ?})
          (set-outcome ?dv-rel /succ))))

    (try
      (role ?org {@self duty-to ?org recruit-staff})
      (role ?wp {?org workplace ?wp})
      (role ?held [k letter] (spatial ?held held-by @self)
                             (substantial (attr ?held destination)))
      (no-role [k outgoing-mail-stack])
      (effects (maintain-proposal {@self locate [k outgoing-mail-stack] ?wp})))))
