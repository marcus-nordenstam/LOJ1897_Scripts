; (near ?a ?b): a PROXIMITY weight (higher = closer) for a role's
; (select (score (near @self ?venue)) (policy roulette)) selector. Mirrors the old
; venue picker's `base + pull/(1+dist)`: a 0.1 floor keeps every known venue reachable,
; plus a 1/(1+distance) pull toward the near ones. Roulette (not argmin) so the
; town SPREADS across the venues it knows instead of every NPC funnelling into the
; single nearest one (which overruns a venue's occupancy).
(define-func near (?a ?b)
  (+ 0.1 (/ 1.0 (+ 1.0 (distance ?a ?b)))))
