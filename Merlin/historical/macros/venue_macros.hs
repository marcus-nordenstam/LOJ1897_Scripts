; ----------------------------------------------------------------------------
; venue_macros.hs - the shared "go to a venue and do an act there" proposal.
;
; (propose-venue-act ?venue ?act): the effect every venue-lane THINK shares. ?venue
; is a KNOWN building the THINK already settled on by role-casting (a role filtered
; to the venue kind with (prefer (distance @self ?venue)) (policy argmin) -> the
; nearest one the NPC knows). If already AT ?venue, propose the ?act act-goal there;
; otherwise propose a `go` sub-act-goal to it. Knowledge-honest by construction - the
; role never binds a venue the NPC has not learned, so no omniscient venue pick. Two
; thinks that settle on the SAME (?venue, ?act) stack their utility on the one
; act-goal (additive source aggregation).
;
;   worship:  (propose-venue-act ?venue worship)   with a (role ?venue [k building church] ...)
;   (reused by any go-there-and-do-it lane: drink/pub, gamble/pub, alms/church...)
; ----------------------------------------------------------------------------

(define-macro propose-venue-act (?venue ?act)
  (if (at-place ?venue)
      (begin-goal {@self ?act ?venue})
      (if (and (is-entity ?venue) (not (= ?venue @self)))
          (begin-goal {@self go ?venue}))))

; (near ?a ?b): a PROXIMITY weight (higher = closer) for a role's
; (prefer (near @self ?venue)) (policy weighted) selector. Mirrors the old venue
; picker's `base + pull/(1+dist)`: a 0.1 floor keeps every known venue reachable,
; plus a 1/(1+distance) pull toward the near ones. Weighted (not argmin) so the
; town SPREADS across the venues it knows instead of every NPC funnelling into the
; single nearest one (which overruns a venue's occupancy).
(define-macro near (?a ?b)
  (+ 0.1 (/ 1.0 (+ 1.0 (distance ?a ?b)))))
