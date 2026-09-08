; ----------------------------------------------------------------------------
; prepare-application ?wp ?jk - write and envelope a job application FORM: pen the
; blank, fill the applicant / home / job fields, address it to the workplace. One
; sequence: each stage reads the paper in hand for what is already done, so a restarted
; errand never pens a second form. The form is left in hand for the mail lane.
; ----------------------------------------------------------------------------

(npc-task {@self prepare-application ?wp ?jk}:?pa-rel
  (tar building)
  (aux job)
  (sequence

    (stage
      (effects
        (if (empty (spatial @self hold [k application]))
            (then (maintain-proposal {@self CREATE-ENTITY [k application]}:?ce
                    [/postlude (bind (bb-read ?ce created) ?app)]))
            (else (bind (head (spatial @self hold [k application])) ?app)))))

    (stage
      (when {@self name ?myName}
            {@self home ?myHome}
            {?myHome address ?myAddress})
      (effects
        (if (unsubstantial (attr ?app writing))
            (then (maintain-proposal
                    {@self WRITE ?app [[applicant ?myName] [home ?myAddress] [job ?jk]]})))))

    (stage
      (when {?wp address ?wpAddress})
      (effects
        (if (unsubstantial (attr ?app address))
            (then (maintain-proposal {@self ADDRESS ?app ?wpAddress})))))

    (stage
      (effects (set-outcome ?pa-rel /succ)))))
