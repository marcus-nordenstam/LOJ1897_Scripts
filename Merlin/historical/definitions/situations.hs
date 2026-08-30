; ----------------------------------------------------------------------------
; situations.hs - the classifier tuning that is still C++-side.
;
; Loaded at ontology-load time (hsim::derive_load_norms, from
; t_simulator::load_ontology). Every value here is also the built-in C++ default,
; so the model runs unchanged if this file is removed.
;
; Only classify_identities remains: the dimension, conduct and rank-curve tuning
; moved out with their classifiers, which are authored .hs now (the dims in
; macros/dimensions.hs, the curves in tables/lookup-tables.hs). This file goes
; away entirely once identities are authored too.
; ----------------------------------------------------------------------------

; ---- identity-thresholds (PR-3b 2026-05-25) --------------------------------
; Role-identity classifier floors for hsim_derive::classify_identities.
; The bond / class / job / church identities have no threshold (they fire on
; structural presence); only the trait-composite identities need tunable
; cutoffs.
;
; machiavellian-min / sadist-min: floor on the homonymous Dark Tetrad attr
;   (0..1 float, population mean 0.5). 0.65 places the threshold near the
;   top third of the population given typical gaussian sigma 0.15.
(identity-thresholds
  /machiavellian-min     0.65
  /sadist-min            0.65)
