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

; --- THINK: a quality-home OWNER takes on the standing staffing duty -----------
; The slow dispositional (window-start) pass, per NPC. consider-staffing checks
; - from self-beliefs - whether @self owns a manor/townhouse, and if so mints the
; {@self goal {@self staff_household}} standing duty once. Tenants / co-resident
; spouses own no quality home and never take it on. The ACT below fulfils it.
(hsim-event consider_household_staffing
  (sim-window-start)
  (nl         "@self resolves to keep their household in service")
  (rng-stream employment)

  (roles
    (role @self (template any_human)
                (>= (years-old @self) 21)
                (believes @self {@self home ?})))

  (effects (consider-staffing @self)))

; --- ACT: the head fulfils the duty - founds + hires what the household lacks ---
(hsim-event staff_household
  (nl         "?actor takes on domestic staff")
  ; EMERGENT: no (schedule) - fired by the per-NPC emergent pass MONTHLY. The
  ; (generative-staffing) dispatch (run_generative_staffing) now GATES on the
  ; {@self goal {@self staff_household}} duty the think minted, then FILLS-TO-TARGET
  ; (hsim::staff_household founds the org if needed + hires the shortfall, updating
  ; the env register AND each servant's mind). It no-ops once full - self-throttles
  ; - so the standing duty needs no clearing.
  (rng-stream employment)
  (generative-staffing)

  (roles
    (role ?actor (template any_human)
                 (>= (years-old ?actor) 21)
                 (believes ?actor {@self home ?}))))
