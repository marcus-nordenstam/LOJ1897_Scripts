; ----------------------------------------------------------------------------
; prepare-application ?job - write and envelope a job application FORM for ONE seat: pen
; the blank, fill the applicant / home / seat fields (the seat's kind, its org's name and
; its line - what lets the reader land on the same seat object), address it to the org's
; door. One sequence: the form it fills is the one it CREATED, kept under the running
; task's own key, so a restarted errand re-reads that key instead of penning a second
; form. The form is left for the mail lane.
; ----------------------------------------------------------------------------

(npc-task {@self prepare-application ?job}:?pa-rel
  (aspect labour)
  (tar [k job] @object)
  (sequence

    (stage
      (effects
        (if (bb-any ?pa-rel application)
            (then (bind (bb-read ?pa-rel application) ?app))
            (else (maintain-proposal {@self CREATE-ENTITY [k application]}:?ce
                    [/postlude (bind (bb-read ?ce created) ?app)
                               (bb-write ?pa-rel application ?app)])))))

    ; The paper must be WITHIN REACH - the very thing WRITE checks - so the stage that
    ; proposes WRITE is what guarantees it. An errand interrupted mid-form leaves the
    ; blank where it lay, and the stage HOLDS until he is back at it.
    (stage
      (when (spatial ?app co-located @self)
            {@self name ?myName}
            {@self home ?myHome}
            {?myHome address ?myAddress}
            {?job org ?org}
            {?org name ?orgName}
            {?org workplace ?wp}
            {?wp address ?wpAddress}
            {?job job-id ?line}
            (kind ?job): ?jk)
      (effects
        (bind (date-now) ?today)
        (if (unsubstantial (attr ?app writing))
            (then (maintain-proposal
                    {@self write-doc ?app (table-msg [/addressee ?orgName /address ?wpAddress]
                                                 [[applicant ?myName] [home ?myAddress]
                                                  [job-kind ?jk] [org-name ?orgName]
                                                  [job-id ?line] [date ?today]])})))))

    (stage
      (effects (bb-clear ?pa-rel application)
               (set-outcome ?pa-rel /succ)))))
