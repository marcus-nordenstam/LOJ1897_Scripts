; ----------------------------------------------------------------------------
; covet_inheritance.hs - instrumental (appetitive) homicide genesis.
;
; The appetitive counterpart to the reactive pressure-deliberation path
; (deliberate.hs). Where deliberation turns a GRIEVANCE into a goal against the
; wrongdoer, this event turns a WANT (a wealthier relative's fortune) into a
; goal against an INNOCENT obstacle - the rich kin. The victim is selected for
; what removing them achieves (the inheritance), not for anything they did.
;
; The `(generative-covet)` flag dispatches to hse_engine.cc::run_generative_covet,
; which (per alive human, monthly):
;   1. disposition pre-gate (machiavellianism + psychopathy, x disinhibition),
;   2. finds the wealthiest known LIVING kin richer than the actor by a floor,
;   3. mints {actor goal {actor kill <kin>}} with the kin's wealth belief as
;      the goal's /cause (so the rap-sheet chain reads "kill <kin> <- wealth").
; attempt_harm then consumes the goal and executes a kill method as usual.
;
; Kept rare by design - see k_covet_base_rate in run_generative_covet. To A/B
; the motive, rename/remove this file (runtime-loaded; no rebuild).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event covet_inheritance
  (nl       "?actor covets a wealthier relative's fortune")
  (rng-stream perpetration)
  (generative-covet)

  (roles
    (role ?actor (template any_human))))
