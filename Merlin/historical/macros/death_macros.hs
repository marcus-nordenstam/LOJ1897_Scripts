; ----------------------------------------------------------------------------
; death_macros.hs - death + burial propagation, expressed over atomic ops.
;
; (propagate-death ?dead) is the ONE sanctioned director-channel sweep that runs
; when a person dies (natural death, suicide, kill - every terminal calls it).
; It walks the deceased's OWN social-tie beliefs (the kin / bond / loose label
; alts below, one deduped pass, via the /their-mind for-each - the sanctioned
; director read of the SUBJECT's own mind, not @self's beliefs about them) and,
; for each survivor:
;   - checks the heir prospect FIRST ({?svr heir_of ?dead}, read before the
;     end-all wipes it),
;   - interval-ends EVERY belief the survivor holds about the deceased at
;     UNFORGETTABLE salience ("X WAS my spouse" survives for life; the default
;     salience would wipe the memory on the next sleep sweep),
;   - asserts the fresh ongoing {?dead condition [k dead]} belief (its
;     interval-start IS the death time; "alive" is its absence),
;   - converts a held heir prospect to the realised {?svr inherit _ ?dead}.
; Then the engine atomics settle the world: goals nesting the deceased retire
; across all minds, a vacated leadership post backfills, the roster entry drops,
; the estate passes, and (die) marks the corpse (condition attr + mind status).
; The corpse is NOT destroyed here - burial's sweep does that.
;
; (propagate-burial ?corpse) closes the death loop at the graveside: every tie
; of the corpse learns {?corpse condition [k buried]} - the funeral / parish
; register is public knowledge, the same channel the death itself travelled.
; This is what releases the town's convey / bury filters: without it every
; absent knower kept an unforgettable dead-and-unburied belief forever and
; re-scanned it at every deliberation. Must run BEFORE (destroy-entity ?corpse)
; - the walk reads the corpse's own tie beliefs (never ended by the death sweep).
; ----------------------------------------------------------------------------

(define-macro propagate-death (?dead)
  (do
    (for-each-belief {?dead mother|father|parent|sibling|half_sibling|brother|sister|child|grandmother|grandfather|grandparent|grandchild|aunt|uncle|niece|nephew|cousin|mother_in_law|father_in_law|parent_in_law|sister_in_law|brother_in_law|sibling_in_law|daughter_in_law|son_in_law|child_in_law|stepmother|stepfather|stepchild|spouse|fiancee|friend|lover|acquaintance|neighbour|enemy ?svr /their-mind}
      (do
        (bind (believes ?svr {?svr heir_of ?dead}) ?was_heir)
        (end-beliefs-about ?svr ?dead /salience unforgettable /reason died)
        (begin-belief-in ?svr {?dead condition [k dead]})
        (if ?was_heir (then (begin-belief-in ?svr {?svr inherit _ ?dead})))))
    (end-goals-nesting ?dead)
    (promote-on-vacancy ?dead)
    (fire /worker ?dead)
    (inherit-orgs ?dead)
    (inherit-estate ?dead)
    (inherit-money ?dead)
    (die ?dead)))

(define-macro propagate-burial (?corpse)
  (for-each-belief {?corpse mother|father|parent|sibling|half_sibling|brother|sister|child|grandmother|grandfather|grandparent|grandchild|aunt|uncle|niece|nephew|cousin|mother_in_law|father_in_law|parent_in_law|sister_in_law|brother_in_law|sibling_in_law|daughter_in_law|son_in_law|child_in_law|stepmother|stepfather|stepchild|spouse|fiancee|friend|lover|acquaintance|neighbour|enemy ?svr /their-mind}
    (begin-belief-in ?svr {?corpse condition [k buried]})))
