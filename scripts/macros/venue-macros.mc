; ----------------------------------------------------------------------------
; venue_macros.hs - the venue-proximity weight for role selectors.
;
; (The old (propose-venue-act ...) routing macro is RETIRED - venue routing now mints
; {@self enter ?venue} into the generic enter chain, §5.11.)
; ----------------------------------------------------------------------------

; (near ?a ?b): a PROXIMITY weight (higher = closer) for a role's
; (select (score (near @self ?venue)) (policy roulette)) selector. Mirrors the old
; venue picker's `base + pull/(1+dist)`: a 0.1 floor keeps every known venue reachable,
; plus a 1/(1+distance) pull toward the near ones. Roulette (not argmin) so the
; town SPREADS across the venues it knows instead of every NPC funnelling into the
; single nearest one (which overruns a venue's occupancy).
(define-macro near (?a ?b)
  (+ 0.1 (/ 1.0 (+ 1.0 (distance ?a ?b)))))
