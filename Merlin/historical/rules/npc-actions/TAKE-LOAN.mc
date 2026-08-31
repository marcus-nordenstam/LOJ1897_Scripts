; ----------------------------------------------------------------------------
; borrow_errand (act lane) - the npc-ACT half of the borrowing split (Item 5).
; The go/dwell think rungs live in npc-think/borrow_errand.hs.
;
; The decision (borrowing_think.hs) minted {@self goal {@self TAKE_LOAN <creditor>}}. The
; debtor calls on his creditor (the lender) at home and the debt is struck there -
; a located commit with the co-presence a witness would see, instead of a faceless
; world edit. The creditor is the goal focus; the debtor navigates to the lender's
; home he ALREADY KNOWS - his OWN belief {?creditor home ?h}, mirrored when they
; became acquainted (no telepathy: we never read the creditor's mind). If he does
; not know where the creditor lives, the bind fails and the call cannot be made
; (a directory lookup to acquire an unknown address is future work).
;
;   borrow_commit : the dwell completion (completion-only) - records {@self owe
;                   <creditor>}; the borrowing_done twin ends the goal off it.
; ----------------------------------------------------------------------------

; The 45-min call, promoted from the TAKE_LOAN aim at the lender's home; matched by its
; (when) on the promoted {@self TAKE_LOAN} belief. Records the debt, ends act + aim.
(npc-action {@self TAKE_LOAN ?lender}
  (duration 45)
  (effects
    (begin-belief {@self owe ?lender})
    (set-outcome {@self TAKE_LOAN} /succ)))
