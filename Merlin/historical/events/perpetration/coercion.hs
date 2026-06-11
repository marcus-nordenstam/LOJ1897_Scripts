; ----------------------------------------------------------------------------
; coercion - the repeat-demand loop (see Docs/hsim/hsim_crime.md "Blackmail /
; coercion").
;
; An actor holding a standing coercion anchor ({@self extort X /aux <demand>},
; the ONGOING verb state the silence_coerce perpetration terminal mints - the
; `coerce` TASK label commits as a point-interval act-record and would never
; read back as standing) re-presses the demand monthly. The
; `(generative-coercion)` flag dispatches to
; hsim/hse_engine.cc::run_generative_coercion, which per anchor:
;   1. ends it if the victim is dead, the demand is met (the coerced match -
;      a substrate scar, no crime), or the secret has leaked into any third
;      mind (published / confessed / intercepted / gossiped - spent leverage);
;   2. else REFRESHES the victim's exposure_risk (mint_pressure compounds the
;      salience, so the standing demand is what walks the victim from bribe /
;      confess_letter toward the kill tail across ticks - no scripted
;      escalation) and rides a blackmail note down the covert letter channel
;      (interception or cache = the coercion evidence trail).
;
; Cast: any alive human holding at least one coerce anchor - the same cheap
; existence-test shape attempt_harm uses for goals.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event coercion
  (nl       "?actor presses a standing demand")
  (kind     _coercion)
  (schedule (monthly))
  (band      night)
  (rng-stream perpetration)
  (generative-coercion)

  (roles
    (role ?actor (template any_human)
                 (> (count-beliefs ?actor extort) 0))))
