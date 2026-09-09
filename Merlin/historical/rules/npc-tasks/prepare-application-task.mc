; ----------------------------------------------------------------------------
; prepare-application ?wp ?jk - write and envelope a job application FORM: pen the
; blank, fill the applicant / home / job fields, address it to the workplace. One
; sequence: the form it fills is the one it CREATED, kept under the running task's own
; key, so a restarted errand re-reads that key instead of penning a second form. The
; form is left for the mail lane.
; ----------------------------------------------------------------------------

(npc-task {@self prepare-application ?wp ?jk}:?pa-rel
  (tar building)
  (aux job)
  (sequence

    (stage
      (effects
        (if (bb-any ?pa-rel application)
            (then (bind (bb-read ?pa-rel application) ?app))
            (else (maintain-proposal {@self CREATE-ENTITY [k application]}:?ce
                    [/postlude (bind (bb-read ?ce created) ?app)
                               (bb-write ?pa-rel application ?app)])))))

    (stage
      (when {@self name ?myName}
            {@self home ?myHome}
            {?myHome address ?myAddress})
      (effects
        (if (unsubstantial (attr ?app writing))
            (then (maintain-proposal
                    {@self WRITE ?app (table-msg [[applicant ?myName] [home ?myAddress] [job ?jk]])})))))

    (stage
      (when {?wp address ?wpAddress})
      (effects
        (if (unsubstantial (attr ?app destination))
            (then (maintain-proposal {@self ADDRESS ?app ?wpAddress})))))

    (stage
      (effects (bb-clear ?pa-rel application)
 (set-outcome ?pa-rel /succ)))))
