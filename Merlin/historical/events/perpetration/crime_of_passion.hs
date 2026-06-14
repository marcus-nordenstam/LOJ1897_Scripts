; ----------------------------------------------------------------------------
; crime_of_passion.hs - instrumental homicide genesis: obsession.
;
; Sibling of covet_inheritance.hs. An actor consumed by one-sided attraction
; (a `crave` stance toward a beloved) turns murderous: kill the RIVAL for the
; beloved's affections (the beloved's spouse / lover - an innocent obstacle, the
; instrumental case), or, when no rival is known, the spurned beloved themselves
; ("if I can't have you...", the passion case).
;
; The `(generative-obsession)` flag dispatches to
; hse_engine.cc::run_generative_obsession, which (per alive adult, monthly):
;   1. jealous-rage pre-gate (volatility + psychopathy, x disinhibition),
;   2. walks the actor's `crave` attractions,
;   3. picks the rival (beloved's spouse/lover) else the beloved,
;   4. mints {actor goal {actor kill <victim>}} with the crave belief as the
;      goal's /cause (so the rap-sheet reads "kill <victim> <- {@self crave ...}").
; attempt_harm then consumes the goal and executes a kill method as usual.
;
; Kept rare by design (k_obsession_base_rate). To A/B, rename/remove this file.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event crime_of_passion
  (nl       "?actor's obsession turns murderous")
  (kind     _crime_of_passion)
  (band      night)
  (rng-stream perpetration)
  (generative-obsession)

  (roles
    (role ?actor (template any_human))))
