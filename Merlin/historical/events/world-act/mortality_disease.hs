; ----------------------------------------------------------------------------
; Background disease mortality. A flat low per-month chance independent of
; age - in the historical sim this models the steady drumbeat of fevers,
; consumption, accidents, and respiratory illness that didn't respect class
; or age but still claimed lives well outside the old-age bracket.
;
; Pandemic surges (cholera, smallpox, typhus) layer on top via dedicated
; pandemic .hse events with their own schedules.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event mortality_disease
  (nl         "?who dies of disease")
  ; EMERGENT (Section 4.11): no (schedule) - fired by the per-NPC emergent pass.
  ; The (when (chance ...)) below IS the rate; the monthly pass is the cadence.
  (rng-stream deaths)

  (roles
    (role ?who (template any_human)
               (>= (years-old ?this) 1)))

  (when (chance 0.0008))   ; ~1% per year background disease rate

  (effects
    ; propagate-death MUST precede die - (die ?who) destroys the entity and
    ; recycles the abs symbol, after which the sweep can't find it. The
    ; helper interval-ends every belief surviving minds hold about ?who and
    ; asserts a fresh ongoing {?who condition dead} belief in each. See
    ; hsim_belief_propagation.cc.
    (propagate-death ?who)
    (die             ?who :cause disease)
    (log             _death ?who)))
