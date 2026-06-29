; ----------------------------------------------------------------------------
; borrow_errand - the npc-ACT half of the borrowing split (Item 5).
;
; The decision (borrowing.hs) minted {@self goal {@self borrow <creditor>}}. The
; debtor calls on his creditor (the lender) at home and the debt is struck there -
; a located commit with the co-presence a witness would see, instead of a faceless
; world edit. The creditor is the goal focus; the debtor navigates to the lender's
; home he ALREADY KNOWS - his OWN belief {?creditor home ?h}, mirrored when they
; became acquainted (no telepathy: we never read the creditor's mind). If he does
; not know where the creditor lives, the bind fails and the call cannot be made
; (a directory lookup to acquire an unknown address is future work).
;
;   borrow_go     : hold the goal, not at the lender's home -> travel act to it.
;   borrow_dwell  : hold the goal, AT the lender's home -> a short dwell (the call).
;   borrow_commit : the dwell completion (completion-only) - records {@self owe
;                   <creditor>} + clears the goal.
; ----------------------------------------------------------------------------

(hsim-event borrow_go
  (intra-day)
  (bind (goal-focus take_loan) ?creditor)
  (when (and (has-goal take_loan)
             (bind {?creditor home ?cred_home})
             (not (at-place ?cred_home))))
  (utility 60)
  (effects (go @self ?cred_home)))

(hsim-event borrow_dwell
  (intra-day)
  (bind (goal-focus take_loan) ?creditor)
  (when (and (has-goal take_loan)
             (bind {?creditor home ?cred_home})
             (at-place ?cred_home)))
  (utility 60)
  (effects (act borrow_commit 45)))

(hsim-event borrow_commit
  (schedule (completion-only))
  (effects
    (begin-belief {@self owe (goal-focus take_loan)})
    (end-goal {@self take_loan})
    ))
