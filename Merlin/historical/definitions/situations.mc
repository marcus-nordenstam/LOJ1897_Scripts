; ----------------------------------------------------------------------------
; situations.mc - the classifier tuning that is still C++-side, as a .mc
; define-list parsed by the shared list/table coordinator.
;
; Only classify_identities remains (dimension/conduct/rank-curve tuning moved to
; authored .hs). Every value here is also the built-in C++ default, so the model
; runs unchanged if this file is removed.
; ----------------------------------------------------------------------------

; Role-identity classifier floors for hsim_derive::classify_identities. The
; machiavellian / sadist thresholds floor the homonymous Dark Tetrad attr
; (0..1, population mean 0.5); 0.65 sits near the top third.
(define-list identity_thresholds
  machiavellian-min 0.65
  sadist-min        0.65)
