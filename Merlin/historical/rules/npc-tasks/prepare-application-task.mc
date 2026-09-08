; ----------------------------------------------------------------------------
; prepare-application ?wp ?jk - fill in a job application FORM (born at @self's home,
; mailed to the workplace ?wp). A COMPOSITION of general lego acts:
;   CREATE-ENTITY [k application]  : take a blank form;
;   WRITE ?app [[applicant ..] [home ..] [job ..]] : fill it in - who is applying (by
;       NAME, so the hiring officer resolves the applicant), where they live (by ADDRESS,
;       so the verdict can be posted back), for which role;
;   ADDRESS ?app <the workplace's address> : the envelope, for the mail service.
; Every rung reads the PREVIOUS act's own outcome record, never the paper's attrs (which
; no wake watches). The finished form is handed to the mail lane by apply-for's send rung.
; ----------------------------------------------------------------------------

(npc-task {@self prepare-application ?wp ?jk}:?pa-rel
  (tar building)
  (aux job)
  (and
    (try
      (when -{@self CREATE-ENTITY [k application] /succ /caused_by ?pa-rel})
      (utility fallback)
      (effects
               (maintain-proposal {@self CREATE-ENTITY [k application]})))
    (try
      (role @self {@self CREATE-ENTITY [k application] /succ /caused_by ?pa-rel}:?ce
                  {@self name ?myName}
                  {@self home ?myHome}
                  {?myHome address ?myAddress}
                  -{@self WRITE ? ? /succ /caused_by ?pa-rel})
      (effects
               (bb-read ?ce created): ?app
               (maintain-proposal {@self WRITE ?app [[applicant ?myName] [home ?myAddress] [job ?jk]]})))
    (try
      (role @self {@self WRITE ?app ? /succ /caused_by ?pa-rel}
                  {?wp address ?wpAddress}
                  -{@self ADDRESS ?app ? /succ /caused_by ?pa-rel})
      (effects
               (maintain-proposal {@self ADDRESS ?app ?wpAddress})))
    (try
      (role @self {@self ADDRESS ? ? /succ /caused_by ?pa-rel})
      (effects (set-outcome ?pa-rel /succ)))))
