; ----------------------------------------------------------------------------
; affair_fallout.hs - broad, NON-lethal betrayal fallout (homicide_motive_realism
; pattern-4 + divorce). The counterpart to crime_of_passion.hs: where that pass
; is the murderous tail (a betrayed spouse KILLS), this is what happens to
; EVERYONE else who is betrayed - the great majority who react without violence.
;
; The `(generative-betrayal)` flag dispatches to hse_engine.cc::
; run_generative_betrayal, which (per alive adult, monthly, gated by a discovery
; probability so the affair surfaces over time):
;   1. discover the partner's third-party affair (shared discover_affair),
;   2. appraise_betrayal -> mints anger@partner + contempt@interloper + a
;      humiliation PRESSURE; the pressure feeds the ordinary deliberation table
;      (humiliation -> confront_privately / expose / humiliate / withdraw), so
;      the betrayed spouse confronts / exposes / shames the cheat over later ticks,
;   3. a decorum-weighted roll may DIVORCE the cheat outright - ending the
;      {spouse} bond on both sides (the first modelled marriage dissolution; a
;      divorcee is then eligible to re-court via lovers / betrothal).
;
; No kill goal is minted here - lethal betrayal stays with crime_of_passion.hs.
; Kept from firing every month by the discovery probability; once a spouse
; divorces, the bond is gone so they are no longer a betrayed-spouse candidate.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event affair_fallout
  (nl       "?actor reckons with a partner's affair")
  (kind     _affair_fallout)
  (schedule (monthly))
  (band      evening)
  (rng-stream incidents)
  (generative-betrayal)

  (roles
    (role ?actor (template any_human))))
