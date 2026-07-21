; ----------------------------------------------------------------------------
; borrow_errand (act lane) - the npc-ACT half of the borrowing split (Item 5).
; The go/dwell think rungs live in npc-think/borrow_errand.hs.
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
;   borrow_commit : the dwell completion (completion-only) - records {@self owe
;                   <creditor>} + clears the goal.
; ----------------------------------------------------------------------------

; The 45-min call, promoted from the take_loan aim at the lender's home; matched by its
; (when) on the promoted {@self take_loan} belief. Records the debt, ends act + aim.
(npc-act take_loan_act
  (act {@self take_loan})
  (duration 45)
  (act-effects
    (begin-belief {@self owe (goal-focus take_loan)})
    (end-act {@self take_loan})))
