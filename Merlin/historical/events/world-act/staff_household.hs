; ----------------------------------------------------------------------------
; staff_household.hs - domestic-service staffing of quality homes
; (see Docs/hsim/hsim_social.md "Households").
;
; The `(generative-staffing)` flag dispatches to hse_engine.cc::
; run_generative_staffing, which (per candidate, annually):
;   1. requires the actor to OWN the quality home they live in (manor /
;      townhouse - the household head; tenants and co-resident spouses skip),
;   2. founds the `org household` establishment seated AT the home (its
;      employee_register doubles as the servants' wage book) when none exists,
;   3. fills vacant roster slots (manor: steward / cook / 2 maids / gardener;
;      townhouse: cook / maid) from the jobless lower-class adult pool,
;      acquainting each new servant with the head + spouse and seeding a
;      temperament-fit warmth stance (the hostile-staff lever).
;
; The household is an ORDINARY org, so the establishment is inherited /
; dissolved with the rest of the estate by propagate_death, and servants are
; ordinary employees (fire / promote / job objects all apply). The staff are
; the interception / surveillance surface of the covert-affair plan (Phases
; 1 + 3) - and substrate for theft / witness / class-friction stories
; generally. Refills annually as servants die or move on.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event staff_household
  (nl         "?actor takes on domestic staff")
  ; EMERGENT (Section 4.11): no (schedule) - fired by the per-NPC emergent pass
  ; MONTHLY. No (chance) needed: staff_household is FILL-TO-TARGET (hsim::
  ; staff_household returns 0 when the establishment is fully staffed), so monthly
  ; firing just refills vacancies promptly (within a month vs a year) and no-ops
  ; once full - it self-throttles.
  (rng-stream employment)
  (generative-staffing)

  (roles
    (role ?actor (template any_human)
                 (>= (years-old ?actor) 21)
                 (believes ?actor {@self home ?}))))
