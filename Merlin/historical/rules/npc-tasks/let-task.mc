; ----------------------------------------------------------------------------
; let ?prop - an owner advertises his vacant dwelling ?prop to let: pen a listing,
; inscribe the message a reader adopts (the building is offered to let), lodge it on
; the agency's to-let register, then mint his OWN {?prop availability for-rent} belief
; (the durable "advertised to let" signal landlord_estate / list_to_let consume, and the
; latch that retracts the standing let intent). One sequence; each stage reads the
; listing in hand for what is already done. Promoted at the house agency office.
; ----------------------------------------------------------------------------

(npc-task {@self LET ?prop}:?let-rel
  (tar @excl building)
  (sequence
    (stage
      (effects
        (if (empty (spatial @self hold [k for-lease-listing]))
            (then (maintain-proposal {@self CREATE-ENTITY [k for-lease-listing]}:?ce
                    [/postlude (bind (bb-read ?ce created) ?listing)]))
            (else (bind (head (spatial @self hold [k for-lease-listing])) ?listing)))))

    (stage
      (effects
        (if (unsubstantial (attr ?listing writing))
            (then (maintain-proposal
                    {@self WRITE ?listing (written-msg {?prop availability [k for-rent]})})))))

    (stage
      (role ?stk [k for-lease-listing-stack])
      (effects (maintain-proposal {@self STACK-PUT ?listing ?stk})))

    (stage
      (effects
        (begin-belief {?prop availability [k for-rent]})
        (set-outcome ?let-rel /succ)))))
