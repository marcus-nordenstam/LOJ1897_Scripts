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

(npc-think borrow_go
  (short-term-think)
  (goal {@self take_loan})
  (bind (goal-focus take_loan) ?creditor)
  (when (and (bind {?creditor home ?cred_home})
             (not (at-place ?cred_home))))
  (utility 60)
  (cont-fire-effects (excl-goal {@self go ?cred_home})))

(npc-think borrow_dwell
  (short-term-think)
  (goal {@self take_loan})
  (bind (goal-focus take_loan) ?creditor)
  (when (and (bind {?creditor home ?cred_home})
             (at-place ?cred_home)))
  (utility 60)
  (effects (begin-act {@self take_loan} 45 borrow_commit)))

(npc-think borrow_commit
  (on-completion)
  (effects
    (begin-belief {@self owe (goal-focus take_loan)})
    (end-goal {@self take_loan})
    ))
