; ----------------------------------------------------------------------------
; borrow_errand - the npc-ACT half of the borrowing split (Item 5).
;
; The decision (borrowing.hs) minted {@self goal {@self borrow <creditor>}}. The
; debtor calls on his creditor (the lender) at home and the debt is struck there -
; a located commit with the co-presence a witness would see, instead of a faceless
; world edit. The creditor is the goal focus, so the destination composes from the
; generic ops: (home-of (goal-focus take_loan)) - the lender's home (deterministic, so
; arrival is gated on that same instance, no kind-fallback needed).
;
;   borrow_go     : hold the goal, not at the lender's home -> travel act to it.
;   borrow_dwell  : hold the goal, AT the lender's home -> a short dwell (the call).
;   borrow_commit : the dwell completion (completion-only) - records {@self owe
;                   <creditor>} + clears the goal.
; ----------------------------------------------------------------------------

(hsim-event borrow_go
  (intra-day)
  (nl   "@self calls on a creditor")
  (when (and (has-goal take_loan)
             (not (self-at (home-of (goal-focus take_loan))))))
  (utility 60)
  (effects (go @self (home-of (goal-focus take_loan)))))

(hsim-event borrow_dwell
  (intra-day)
  (nl   "@self arranges a loan")
  (when (and (has-goal take_loan)
             (self-at (home-of (goal-focus take_loan)))))
  (utility 60)
  (effects (act borrow_commit 45)))

(hsim-event borrow_commit
  (schedule (completion-only))
  (nl   "@self borrows from a creditor")
  (effects
    (begin-belief @self owe (goal-focus take_loan))
    (clear-goal @self take_loan)
    (log _borrowing @self)))
