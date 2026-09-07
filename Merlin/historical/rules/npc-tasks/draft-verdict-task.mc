; ----------------------------------------------------------------------------
; draft-verdict ?applicant ?kind - answer ONE applicant (whom @self learned of by
; READing their application) with a verdict letter of ?kind (offer-letter /
; rejection-letter). A COMPOSITION of general lego acts, one dumb step each:
;   CREATE-ENTITY ?kind : pen the blank verdict letter (verdict rides the KIND);
;   ADDRESS ?ltr ?applicant : envelope it to the applicant (name + home);
;   send-mail ?ltr       : the mail lane delivers it to the applicant's home;
; then @self ends his {?applicant apply-for} belief (answered - don't re-draft).
; WHICH verdict is the proposing resolve-applications round's decision, not this task's.
; ----------------------------------------------------------------------------

(npc-task {@self draft-verdict ?applicant ?kind}:?dv-rel
  (track-skill-level [k law])
  (tar human)
  (and
    (try
      (when -{@self CREATE-ENTITY ?kind /succ /caused_by ?dv-rel})
      (utility fallback)
      (effects (maintain-proposal {@self CREATE-ENTITY ?kind})))
    ; The verdict is a FORM naming the applicant, in an envelope addressed to the home the
    ; application gave - both as @self BELIEVES them. An applicant whose address @self
    ; never learned gets no envelope and the letter never leaves.
    (try
      (role @self {@self CREATE-ENTITY ?kind /succ /caused_by ?dv-rel}
                  {?applicant name ?rname}
                  -{@self WRITE ? ? /succ /caused_by ?dv-rel})
      (role ?ltr [k letter] (spatial ?ltr co-located @self) (select (policy first-match)))
      (effects (maintain-proposal {@self WRITE ?ltr [[applicant ?rname]]})))
    (try
      (role @self {@self WRITE ?ltr ? /succ /caused_by ?dv-rel}
                  {?applicant address ?raddress}
                  -{@self ADDRESS ?ltr ? /succ /caused_by ?dv-rel})
      (effects (maintain-proposal {@self ADDRESS ?ltr ?raddress})))
    ; Posted from the OFFICE out-box: answering applications is the recruiting duty, done
    ; at work, never from home. Located first if @self has never seen the office pile.
    (try
      (role ?org {@self duty-to ?org recruit-staff})
      (role ?wp {?org workplace ?wp})
      (role @self {@self ADDRESS ?ltr ? /succ /caused_by ?dv-rel}
                  -{@self locate [k outgoing-mail-stack] ?wp /succ}
                  -{@self locate [k outgoing-mail-stack] ?wp /fail})
      (effects (maintain-proposal {@self locate [k outgoing-mail-stack] ?wp})))
    (try
      (role ?org {@self duty-to ?org recruit-staff})
      (role ?wp {?org workplace ?wp})
      (role ?out [k outgoing-mail-stack] (spatial ?out building ?wp))
      (role @self {@self ADDRESS ?ltr ? /succ /caused_by ?dv-rel}
                  -{@self send-mail ?ltr ? /succ /caused_by ?dv-rel})
      (effects (maintain-proposal {@self send-mail ?ltr ?out})))
    (try
      (when (and {@self send-mail ? ? /succ /caused_by ?dv-rel}
                 {?applicant apply-for ?}))
      (effects
               (end-belief {?applicant apply-for ?})
               (set-outcome ?dv-rel /succ)))))
