; ----------------------------------------------------------------------------
; venue_macros.hs - the shared "go to a venue and do an act there" proposal.
;
; (propose-venue-act ?venue_kind ?act): the effect every venue-lane THINK shares.
; At a venue of ?venue_kind, propose the ?act act-goal there (targeting the
; building); otherwise propose a `go` sub-act-goal to one. Two thinks proposing
; the SAME (?venue_kind, ?act) stack their utility on the one act-goal (additive
; source aggregation) with a single copy of the proposal logic.
;
;   worship:  (propose-venue-act [k building church] worship)
;   (reused by any go-there-and-do-it lane: drink/pub, gamble/pub, alms/church...)
; ----------------------------------------------------------------------------

(define-macro propose-venue-act (?venue_kind ?act)
  (if (at-place-kind ?venue_kind)
      (do (bind (current-building @self) ?place)
          (if (is-entity ?place) (begin-goal {@self ?act ?place})))
      (do (bind (venue ?venue_kind) ?go_dest)
          (if (is-entity ?go_dest) (begin-goal {@self go ?go_dest})))))
