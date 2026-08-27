; ----------------------------------------------------------------------------
; draft_verdict ?applicant ?kind - answer ONE applicant (whom @self learned of by
; READing their application) with a verdict letter of ?kind (offer_letter /
; rejection_letter). A COMPOSITION of general lego acts, one dumb step each:
;   CREATE_ENTITY ?kind : pen the blank verdict letter (verdict rides the KIND);
;   ADDRESS ?ltr ?applicant : envelope it to the applicant (name + home);
;   send_mail ?ltr       : the mail lane delivers it to the applicant's home;
; then @self ends his {?applicant apply_for} belief (answered - don't re-draft).
; WHICH verdict is the proposing resolve_applications round's decision, not this task's.
; ----------------------------------------------------------------------------

(npc-task {@self draft_verdict ?applicant ?kind}:?dv-rel
  (tar human)
  (and
    (try
      (when (none {@self CREATE_ENTITY ?kind /succ /caused_by ?dv-rel}))
      (utility fallback)
      (effects (debug-print "DV_PEN") (maintain-proposal {@self CREATE_ENTITY ?kind})))
    (try
      (role ?ltr [k letter] (spatial ?ltr co-located @self)
            (not (substantial (attr ?ltr addressee))))
      (effects (debug-print "DV_ADDRESS") (maintain-proposal {@self ADDRESS ?ltr ?applicant})))
    (try
      (role ?ltr [k letter] (spatial ?ltr co-located @self)
            (substantial (attr ?ltr addressee)))
      (when (none {@self send_mail ?ltr /caused_by ?dv-rel /ever}))
      (effects (debug-print "DV_SEND") (begin-proposal {@self send_mail ?ltr})))
    (try
      (when (and (any {@self send_mail ? /succ /caused_by ?dv-rel})
                 (any {?applicant apply_for ?})))
      (effects (debug-print "DV_DONE")
               (end-belief {?applicant apply_for ?})
               (set-outcome ?dv-rel succ)))))
