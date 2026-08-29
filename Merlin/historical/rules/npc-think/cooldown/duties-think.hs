; ----------------------------------------------------------------------------
; duties - duty ASSIGNMENT (the capability side of the duty model; the duties an
; org requires live in tables/duty_tables.hs, and behaviour dispatches on the
; HELD duty - {@self duty_to ?org <duty>}, the duty a TASK-LABEL symbol - never on job
; kind or rank).
;
; Every org member reviews his own org's duty allocation monthly. ALL inputs are
; PUBLIC documents (the articles + the wage book) plus his own beliefs - reading
; the ledger is how real org management works, no telepathy: the wage book's
; names internalize into the reader's own mind at the read (think-lane doc
; reads are mental-only end to end).
;
; The seniority argmax picks ONE holder per duty: a head-kind job outranks any
; staff post (+100), then the level rung (+10 x rank), then the wage book's
; append order (= hire order) breaks ties (argmax keeps the FIRST max). Every
; member computes the same answer from the same ledger, so each SELF-assigns
; exactly the duties he wins and drops the ones he no longer does - no
; cross-mind writes anywhere. The org-side mirror ({?org duty_holder <who>
; [k <duty>]}) is each member's own ledger-derived knowledge of who holds what.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think duty_review
  (cooldown 1 m)
  (rng-stream employment)

  (role ?job {@self job ?job})
  (role ?org {?job org ?org}
             {?org record ?})

  (when (and {?org isa ?ok}
             {?org employee_register ?reg}))

  ; The most senior LIVING member on the wage book.
  (select-record (doc [k employee_register] ?reg)
    (bind worker ?senior)
    (bind job ?sjk)
    (bind level ?slvl)
    (when (alive ?senior))
    (score (+ 1 (* 100 (is-a ?sjk [k org_head]))
                (* 10 (if (table-match level_rank level ?slvl rank ?lr) (then ?lr) (else 0)))))
    (policy argmax)
    (else fail))

  (effects
    (if ?senior
        (then
          (for-each-row org_duties (kind ?dk) (duty ?duty)
            (if (is-a ?ok ?dk)
                (then
                  (if (= ?senior @self)
                      (then
                        (if (none {@self duty_to ?org ?duty})
                            (then (begin-belief {@self duty_to ?org ?duty})
                                  (debug-print "DUTY-take ?duty ?org"))))
                      (else
                        (if (any {@self duty_to ?org ?duty})
                            (then (end-belief {@self duty_to ?org ?duty})
                                  (debug-print "DUTY-drop ?duty ?org")))))
                  ; The mirror: retire stale holders, record the current one.
                  (for-each ?dhb-rel (every {?org duty_holder ? ?duty})
                      ?dhb-rel.target: ?p
                      (if (!= ?p ?senior)
                          (then (end-belief {?org duty_holder ?p ?duty}))))
                  (if (none {?org duty_holder ?senior ?duty})
                      (then (begin-belief {?org duty_holder ?senior ?duty}))))))))))
