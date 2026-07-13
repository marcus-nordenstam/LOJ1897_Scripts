; ----------------------------------------------------------------------------
; borrow_errand (think lane) - the npc-THINK half of the borrowing split (Item 5).
; The go/dwell rungs that route the debtor to the lender's home and promote the
; loan-taking act (npc-act/borrow_errand.hs).
;
;   borrow_go     : hold the goal, not at the lender's home -> travel act to it.
;   borrow_dwell  : hold the goal, AT the lender's home -> a short dwell (the call).
; ----------------------------------------------------------------------------

(npc-think borrow_go
  (short-term-think)
  (goal {@self take_loan ?creditor})
  (when (and (bind {?creditor home ?cred_home})
             (not (in-building ?cred_home))))
  (utility 60)
  (cont-fire-effects (go-into ?cred_home)))

(npc-think borrow_dwell
  (short-term-think)
  (goal {@self take_loan ?creditor})
  (when (and (bind {?creditor home ?cred_home})
             (in-building ?cred_home)))
  (utility 60)
  (cont-fire-effects (begin-goal {@self take_loan})))
