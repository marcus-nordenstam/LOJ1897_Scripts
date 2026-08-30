; ----------------------------------------------------------------------------
; prepare_application ?wp ?jk - write the job application paper (born at @self's home,
; mailed to the workplace ?wp). A COMPOSITION of general lego acts:
;   CREATE_ENTITY [k application]           : pen the paper;
;   WRITE ?app {(o {@o name ?myName}) apply_for ?jk} : the real message the hiring
;       officer READs + adopts - who is applying (by NAME, so any reader resolves the
;       applicant) for which role;
;   then stamp the destination = ?wp (the workplace inbox the mail service delivers to).
; The finished paper is handed to the mail lane by the apply_for send rung.
; ----------------------------------------------------------------------------

(npc-task {@self prepare_application ?wp ?jk}:?pa-rel
  (tar building)
  (aux job)
  (and
    (try
      (when -{@self CREATE_ENTITY [k application] /succ /caused_by ?pa-rel})
      (utility fallback)
      (effects (debug-print "PA_PEN")
               (maintain-proposal {@self CREATE_ENTITY [k application]})))
    (try
      (role ?app [k application] (spatial ?app co-located @self)
            (not (substantial (attr ?app writing))))
      (when {@self name ?myName})
      (effects (debug-print "PA_WHO")
               (maintain-proposal {@self WRITE ?app {(o {@o name ?myName}) apply_for ?jk}})))
    (try
      (role ?app [k application] (spatial ?app co-located @self)
            (substantial (attr ?app writing))
            (not (substantial (attr ?app address))))
      (effects (debug-print "PA_ADDR")
               (set-attr ?app address ?wp)
               (set-outcome ?pa-rel /succ)))))
