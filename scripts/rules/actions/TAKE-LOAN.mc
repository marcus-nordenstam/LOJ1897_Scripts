; ----------------------------------------------------------------------------
; TAKE-LOAN ?lender - the debt struck in a 45-minute call at the lender's home (seek-loan-task
; brings the debtor there): records {@self owe ?lender}.
; ----------------------------------------------------------------------------

(action {@self TAKE-LOAN ?lender}:?TAKE-LOAN
  (motor body legs)
  (duration (seconds 45 min))
  (effects
    (begin-belief {@self owe ?lender})
    (set-outcome ?TAKE-LOAN /succ)))
