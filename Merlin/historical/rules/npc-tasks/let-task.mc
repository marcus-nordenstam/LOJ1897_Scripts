; ----------------------------------------------------------------------------
; let ?prop - an owner advertises his vacant dwelling ?prop to let: pen a listing,
; inscribe the message a reader adopts (the building is offered to let), lodge it on
; the agency's to-let register, then mint his OWN {?prop availability for-rent} belief
; (the durable "advertised to let" signal landlord_estate / list_to_let consume, and the
; latch that retracts the standing let intent). One sequence; the listing it inscribes
; is the one it CREATED, kept under the running task's own key, so a restart re-reads
; that key instead of penning a second sheet. Promoted at the house agency office.
; ----------------------------------------------------------------------------

(npc-task {@self LET ?prop}:?let-rel
  (tar @excl building)
  (sequence
    (stage
      (effects
        (if (bb-any ?let-rel listing)
            (then (bind (bb-read ?let-rel listing) ?listing))
            (else (maintain-proposal {@self CREATE-ENTITY [k for-lease-listing]}:?ce
                    [/postlude (bind (bb-read ?ce created) ?listing)
                               (bb-write ?let-rel listing ?listing)])))))

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
        (bb-clear ?let-rel listing)
        (set-outcome ?let-rel /succ)))))
