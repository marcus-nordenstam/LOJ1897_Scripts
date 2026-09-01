; ----------------------------------------------------------------------------
; let ?prop - an owner advertises his vacant dwelling ?prop to let. Replaces the
; crammed LET act: now a COMPOSITION of the general lego acts -
;   CREATE-ENTITY [k for-lease-listing] : pen the listing;
;   WRITE ?listing {?prop availability for-rent} : inscribe the real message a
;       reader adopts (the building is offered to let);
;   STACK-PUT ?listing ?register : lodge it on the agency's to-let register.
; On completion @self mints his OWN {?prop availability for-rent} belief (the
; durable "advertised to let" signal landlord_estate / list_to_let consume, and the
; latch that retracts the standing let intent). Promoted at the house agency office.
; ----------------------------------------------------------------------------

(npc-task {@self LET ?prop}:?let-rel
  (tar @excl building)
  (and
    (try
      (when -{@self CREATE-ENTITY [k for-lease-listing] /succ /caused_by ?let-rel})
      (utility fallback)
      (effects
               (maintain-proposal {@self CREATE-ENTITY [k for-lease-listing]})))
    (try
      (role ?listing [k for-lease-listing] (spatial ?listing co-located @self)
            (not (substantial (attr ?listing writing))))
      (effects
               (maintain-proposal {@self WRITE ?listing {?prop availability [k for-rent]}})))
    (try
      (role ?listing [k for-lease-listing] (spatial ?listing co-located @self)
            (substantial (attr ?listing writing)))
      (role ?stk [k for-lease-listing-stack])
      (when -{@self STACK-PUT ?listing ? /succ /caused_by ?let-rel})
      (effects
               (maintain-proposal {@self STACK-PUT ?listing ?stk})))
    (try
      (when {@self STACK-PUT ? ? /succ /caused_by ?let-rel})
      (effects
               (begin-belief {?prop availability [k for-rent]})
               (set-outcome ?let-rel /succ)))))
