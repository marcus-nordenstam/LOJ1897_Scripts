; ----------------------------------------------------------------------------
; post-ad ?org ?job - put a notice up on the parish board for ONE open post. The post
; is the parameter, so the notice knows what it advertises: the role is the post
; object's OWN kind, not a lookup in a staffing table the officer has no way of
; knowing, and an org with two distinct openings posts two distinct notices.
;
; The notice is the WHOLE sentence the org holds ({?org display-ad ?job} plus where to
; apply), so a seeker who READs the board adopts the org's own fact. One sequence at a
; known church: go there, pen the sheet, write the notice, remember it stands. The
; sibling try searches for a church while none is known. Each stage reads the sheet in
; hand for what is already done, so a restarted posting never pens a second sheet.
; ----------------------------------------------------------------------------

(npc-task {@self post-ad ?org ?job}:?pad-rel
  (tar org)
  (aux job)
  (and
    (sequence
      (role ?board [k building church] (select (score (near @self ?board)) (policy roulette)))

      (stage
        (effects
          (if (not (spatial @self building ?board))
              (then (maintain-proposal {@self enter ?board})))))

      (stage
        (effects
          (if (empty (spatial @self hold [k job-description]))
              (then (maintain-proposal {@self CREATE-ENTITY [k job-description]}:?ce
                      [/postlude (bind (bb-read ?ce created) ?ad)]))
              (else (bind (head (spatial @self hold [k job-description])) ?ad)))))

      (stage
        (when {?org workplace ?wp})
        (effects
          (if (unsubstantial (attr ?ad writing))
              (then (maintain-proposal {@self WRITE ?ad (written-msg {?org display-ad ?job}
                                                                     {?org workplace ?wp})})))))

      (stage
        (effects
          (begin-belief {?org display-ad ?job})
          (set-outcome ?pad-rel /succ))))

    (try
      (no-role [k building church])
      (when (and -{@self find-building [k building church] ? /fail}
                 (current-region @self): ?rg))
      (effects (maintain-proposal {@self find-building [k building church] ?rg})))))
