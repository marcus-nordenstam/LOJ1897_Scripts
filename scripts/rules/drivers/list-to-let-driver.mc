; ----------------------------------------------------------------------------
; list-to-let - the SUPPLY side of the property market (per-NPC replacement for
; the omniscient world-act/landlord_duties.mc). An owner advertises his OWN
; vacant residential building to let, from his OWN knowledge - no world scan.
;
; The annual disposition (a yearly timer) proposes {@self LET ?prop} for each vacant
; dwelling he owns. Vacancy is read entirely from his own beliefs (the
; knowledge-honest signal): a dwelling he owns, that is-a residential, that is
; NOT his home, that he holds no tenant belief for, and that he has not already
; listed. Inheritance deeds him the dwelling ({@self own}); a tenant's death /
; emigration ends his {?prop tenant}, so the vacancy surfaces without a scan.
;
; He proposes the let task (tasks/let-task.mc), which pens the listing, takes it to the
; agency's to-let stack and mints {?prop availability for-rent} - the durable "to let" signal
; landlord_estate.mc reads, and the one that ends this driver's ?prop role. Knowing a to-let
; stack is the task's precondition, so it is this driver's to hold.
; ----------------------------------------------------------------------------


(driver list-to-let
  (cooldown 1 y try-until-succ)
  (role @self {@self age-band [k young-adult|middle-aged|mature|elderly]}
    ; His OWN vacant residential holdings (object-cache role over his beliefs).
    (role ?prop {@self own ?prop}
                {?prop isa [k residential-building]}
                -{@self home ?prop}            ; not where he lives
                -{?prop tenant ?}              ; no sitting tenant
                -{?prop availability [k for-rent]}  ; not already listed
      (role ?stk [k for-lease-listing-stack] (select (policy first-match))
        (declare-utility errand)
        (effects (maintain-proposal {@self LET ?prop}))))))
