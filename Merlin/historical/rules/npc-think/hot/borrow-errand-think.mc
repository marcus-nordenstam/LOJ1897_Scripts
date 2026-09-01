; ----------------------------------------------------------------------------
; borrow_errand (think lane) - the npc-THINK half of the borrowing split (Item 5).
; The go/dwell rungs that route the debtor to the lender's home and promote the
; loan-taking act (npc-act/borrow_errand.hs).
;
;   borrow_go       : hold the goal, not at the lender's home -> travel sub-goal to it.
;   borrow_at_home  : AT the lender's home -> propose the loan-taking act (take_loan_act
;                     reads the creditor off the standing goal focus). The decision
;                     (borrowing_think.hs) begins the goal; its twin outcome rules end it.
; Both rungs are (lock-rule)-locked: one borrowing errand at a time per mind.
; ----------------------------------------------------------------------------

(npc-think borrow_go
  (lock-rule)
  (goal {@self TAKE-LOAN ?creditor})
  (when (and {?creditor home ?cred_home}
             (not (spatial @self building ?cred_home))))
  (effects (maintain-proposal {@self enter ?cred_home})))

; AT the lender's home: PROPOSE the loan-taking act (goals never propose themselves).
; The creditor rides the act target - the act body binds ?lender off the promoted
; {@self TAKE-LOAN <creditor>} belief to record the debt against the right person.
(npc-think borrow_at_home
  (lock-rule)
  (goal {@self TAKE-LOAN ?creditor})
  (when (and {?creditor home ?cred_home}
             (spatial @self building ?cred_home)))
  (effects (maintain-proposal {@self TAKE-LOAN ?creditor})))
