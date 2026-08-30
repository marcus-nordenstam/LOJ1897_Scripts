; ----------------------------------------------------------------------------
; situations.hsc - F3 derived-situation tuning data.
;
; Loaded by Merlin at ontology-load time (hsim::derive_load_norms, called from
; t_simulator::load_ontology). Editing this file re-tunes the F3 four-layer
; derived model - dimensions -> situations -> prototypes - with no rebuild.
; See Docs/hsim_social_events_plan.md F3.5 and src/lib/hsim/hsim_derive.cc.
;
; The classifier LOGIC is code (hsim_derive.cc); only the thresholds, fusion
; weights and the two rank curves live here. Every value below is also the
; built-in C++ default - the model runs unchanged if this file is removed.
;
; Dimensions are integers on a 0..100 scale.
; ----------------------------------------------------------------------------

; ---- dimension tuning ------------------------------------------------------
; Scalars feeding the wealth / breeding classifiers. unemployed-wealth is the
; no-job floor; creditor-wealth-penalty is the wealth lost per outstanding `owe`.
; breeding is a seeded belief with no derived fallback. The prestige curve and its
; bonuses are authored data now - tables/lookup-tables.hs prestige_by_rank plus the
; win / expert terms in macros/dimensions.hs.
(dimension-tuning
  /unemployed-wealth        30
  /creditor-wealth-penalty  15)

; ---- rank curves -----------------------------------------------------------
; Six values, indexed by job rank 0..5 (trainee apprentice junior regular senior
; org_head): the wealth income curve.
(income-by-rank    25 35 50 65 80 95)

; ---- conduct dimensions (Phase 8) ------------------------------------------
; chastity: a high prior (chastity-base), less chastity-adultery-penalty per
; extra-marital partner. gambling-wealth-penalty: the flat wealth hit for a
; standing gambling habit (the play_game act-record).
(conduct
  /chastity-base             85
  /chastity-adultery-penalty 30
  /gambling-wealth-penalty   15)

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
