; ----------------------------------------------------------------------------
; let ?prop - an owner advertises his vacant dwelling ?prop to let. Replaces the
; crammed LET act: now a COMPOSITION of the general lego acts -
;   CREATE_ENTITY [k for_lease_listing] : pen the listing;
;   WRITE ?listing {?prop availability for_rent} : inscribe the real message a
;       reader adopts (the building is offered to let);
;   STACK_PUT ?listing ?register : lodge it on the agency's to-let register.
; On completion @self mints his OWN {?prop availability for_rent} belief (the
; durable "advertised to let" signal landlord_estate / list_to_let consume, and the
; latch that retracts the standing let intent). Promoted at the house agency office.
; ----------------------------------------------------------------------------

(npc-task {@self LET ?prop}:?let-rel
  (tar @excl building)
  (and
    (try
      (when (none {@self CREATE_ENTITY [k for_lease_listing] /succ /caused_by ?let-rel}))
      (utility fallback)
      (effects (debug-print "LET_PEN")
               (maintain-proposal {@self CREATE_ENTITY [k for_lease_listing]})))
    (try
      (role ?listing [k for_lease_listing] (spatial ?listing co-located @self)
            (not (substantial (attr ?listing writing))))
      (effects (debug-print "LET_WRITE")
               (maintain-proposal {@self WRITE ?listing {?prop availability [k for_rent]}})))
    (try
      (role ?listing [k for_lease_listing] (spatial ?listing co-located @self)
            (substantial (attr ?listing writing)))
      (role ?stk [k for_lease_listing_stack])
      (when (none {@self STACK_PUT ?listing ? /succ /caused_by ?let-rel}))
      (effects (debug-print "LET_FILE")
               (maintain-proposal {@self STACK_PUT ?listing ?stk})))
    (try
      (when (any {@self STACK_PUT ? ? /succ /caused_by ?let-rel}))
      (effects (debug-print "LET_DONE")
               (begin-belief {?prop availability [k for_rent]})
               (set-outcome ?let-rel succ)))))
