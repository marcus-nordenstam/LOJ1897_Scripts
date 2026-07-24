; ----------------------------------------------------------------------------
; borrow_errand (think lane) - the npc-THINK half of the borrowing split (Item 5).
; The go/dwell rungs that route the debtor to the lender's home and promote the
; loan-taking act (npc-act/borrow_errand.hs).
;
;   borrow_go     : hold the goal, not at the lender's home -> travel act to it. AT
;                   the lender's home the go sub-goal is spent, the take_loan goal is
;                   the leaf and promotes to take_loan_act - no dwell rung (the decision,
;                   borrowing.hs, owns the goal's whole life).
; ----------------------------------------------------------------------------

(npc-think borrow_go
  (goal {@self take_loan ?creditor})
  (when (and (believes {?creditor home ?cred_home})
             (not (in-building ?cred_home))))
  (utility 60)
  (effects (maintain-proposal {@self enter ?cred_home})))

; AT the lender's home: PROPOSE the loan-taking act (goals never propose themselves).
; take_loan_act reads the creditor off the standing {@self take_loan} goal focus, so the propose
; is label-only.
(npc-think borrow_at_home
  (goal {@self take_loan ?creditor})
  (when (and (believes {?creditor home ?cred_home})
             (in-building ?cred_home)))
  (utility 60)
  (effects (maintain-proposal {@self take_loan})))
