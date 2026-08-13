; ----------------------------------------------------------------------------
; drink_macros.hs - the drink DESIRE predicate + its drive (utility) expression,
; factored so the one desire think and the case sub-rules share them (crave_drink.hs).
; ----------------------------------------------------------------------------

; (drink-due ?actor): the drink-desire condition - a service is ~due (days since the
; last drink) AND the actor is not already dependent (dependents are the relapse.hs
; lane). Perf: most passes skip on the days-since test.
(define-macro drink-due (?actor)
  (and (not (= (any {?actor craving}).target [k alcohol]))
       (>= (days-since-last {?actor drink /ever}) 3)))

; (drink-drive ?actor): the drink UTILITY - a drinking PROPENSITY (low industriousness =
; disinhibition, high withdrawal = self-medication, capped) times a days-since ramp
; (capped as a LEISURE act). Rises until the actor drinks (which resets it), so a
; susceptible man returns to drink regularly while a temperate one never clears a routine
; act. Shared by every rung of the cascade so go / find / drink all compete at the same
; drive.
(define-macro drink-drive (?actor)
  (* (min (+ 0.35
             (* 0.9 (- 1 (attr ?actor industriousness)))
             (* 0.8 (attr ?actor withdrawal))) 1.5)
     (min (* (days-since-last {?actor drink /ever}) 2) 30)))
