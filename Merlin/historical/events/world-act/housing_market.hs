; ----------------------------------------------------------------------------
; Housing market - the buy side of the tenure market (Phase 3a). Once a year the
; house agent's for-sale registry is matched against the people who want their
; own home. A seeker is any adult living in a home they neither own nor lease
; (an adult child still in the natal / inherited home). The wealthiest seekers
; claim the nicest available dwellings - buying them and moving out of the natal
; home (their {@self home ...} is replaced, and the sale reconciles the seller's
; beliefs + removes the listing from the agent's registry).
;
; Supply is whatever has been freed onto the registry by Phase 1
; (death-without-heir, emigration). With FIXED housing this is deliberately
; scarce: only what comes up can be bought, so most adults stay in the natal
; home (or emigrate under the pressure) - realistic scarcity. The rent side and
; richer supply (listing inherited / vacated dwellings, driven by the `occupant`
; occupancy record) are Phase 3b.
;
; Zero-role (see business_failure for the rationale): run-housing-market scans
; entities and runs execute_purchase, which destroys for_sale_listing documents,
; so it must not run inside a role-enumeration walk.
; ----------------------------------------------------------------------------

(hsim-world-event housing_market
  (schedule   (annually march))
  (rng-stream behaviour)

  (effects
    (run-housing-market 20)))
