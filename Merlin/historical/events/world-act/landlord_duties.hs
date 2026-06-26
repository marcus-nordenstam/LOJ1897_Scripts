; ----------------------------------------------------------------------------
; Landlord duties - the supply side of the rent market (Phase 3b). Landlords are
; an occupation: anyone who owns a residential building that nobody lives in
; (vacant - typically inherited, or emptied by death/emigration) puts it on the
; house agent's TO-LET register and takes up the `landlord` occupation. This is
; the landlords "doing their work" - advertising their vacant properties.
;
; Fires in FEBRUARY, a month before the housing market (March), so the to-let
; listings exist before renters come looking. Zero-role (see business_failure):
; run-landlord-duties scans entities and creates listing documents, so it must
; not run inside a role-enumeration walk.
;
; Vacancy is read from where the living actually live (their {@self home ...}),
; the occupancy record - a building with no living resident is available to let.
; ----------------------------------------------------------------------------

(hsim-event landlord_duties
  (schedule   (annually february))
  (rng-stream behaviour)

  (effects
    (run-landlord-duties)))
