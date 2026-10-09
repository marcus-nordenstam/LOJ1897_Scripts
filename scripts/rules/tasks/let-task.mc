; ----------------------------------------------------------------------------
; let ?prop - an owner advertises his vacant dwelling ?prop to let: pen a listing,
; inscribe the message a reader adopts (the building is offered to let), lodge it on
; the agency's to-let register, then mint his OWN {?prop availability for-rent} belief
; (the durable "advertised to let" signal landlord_estate / list-to-let consume, and the
; latch that retracts the standing let intent). One sequence; the listing it inscribes
; is the one it CREATED, kept under the running task's own key, so a restart re-reads
; that key instead of penning a second sheet. Promoted at the house agency office.
; ----------------------------------------------------------------------------

(task {@self LET ?prop}:?LET
  (tar @excl [k building] @object)
  (sequence
    (stage
      (effects
        (if (bb-any ?LET listing)
            (then (bind (bb-read ?LET listing) ?listing))
            (else (maintain-proposal {@self CREATE-ENTITY [k for-lease-listing]}:?CREATE-ENTITY
                    [/postlude (bind (bb-read ?CREATE-ENTITY created) ?listing)
                               (bb-write ?LET listing ?listing)])))))

    (stage
      (effects
        (if (unsubstantial (attr ?listing writing))
            (then (maintain-proposal
                    {@self write-doc ?listing (written-msg [] {?prop availability [k for-rent]})})))))

    ; The listing goes on the agency's pile, which is where the agency keeps it - not on
    ; whichever pile @self happens to know of, from wherever he stands. Walk to it; then
    ; the put is proposed only AT it (STACK-PUT asserts the reach it is given, and a man
    ; can be pulled away between stages), so the stage HOLDS until he is there.
    (stage
      (role ?stk [k for-lease-listing-stack] (select (score (near @self ?stk)) (policy roulette unknown-last)))
      (effects
        (if (not (spatial ?stk co-located @self))
            (then (maintain-proposal {@self go-to ?stk})))))
    (stage
      (role @self (spatial ?stk co-located @self))
      (effects (maintain-proposal {@self STACK-PUT ?listing ?stk})))

    (stage
      (effects
        (begin-belief {?prop availability [k for-rent]})
        (bb-clear ?LET listing)
        (set-outcome ?LET /succ)))))
