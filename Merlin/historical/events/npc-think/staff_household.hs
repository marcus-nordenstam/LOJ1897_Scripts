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
; The slow dispositional (window-start) pass, per NPC, fully declarative: a 21+
; adult who, IN WINTER and not already holding the duty, OWNS the manor / townhouse
; that is their HOME mints the standing goal {@self goal {@self staff_household}}.
; Tenants and co-resident spouses (home is a manor but they do not OWN it) never
; take it on. Clause order matters - the cheap gates short-circuit first so the
; is-a checks run only for winter, dutyless, home-owning candidates; and `?h` is
; BOUND by the first (believes) (the home), then reused to test ownership + kind.
(hsim-event consider_household_staffing
  (sim-window-start)
  (rng-stream employment)

  (roles
    (role @self (template any_human)))

  (when (and (>= (years-old @self) 21)                  ; non-belief age gate -> (when)
             (in-season winter)                        ; once a year - duty is standing
             (not (has-goal staff_household))          ; mint once, then skip
             (believes @self {@self home ?h})          ; BIND ?h = the home
             (believes @self {@self own ?h})           ; @self OWNS that home (the head)
             (or (is-a ?h [k manor]) (is-a ?h [k townhouse]))))

  (effects (begin-goal {@self staff_household})))

; --- FOUND: the head constitutes the household org at his home study -----------
; A separate window-start pass (not season-gated, so it catches the standing duty
; whatever the event load order): a head who holds the staffing duty, OWNS the
; manor / townhouse that is his HOME, and does NOT yet run a household founds the
; `org household` via the shared found-org-seq macro. household is residence-seated
; (businesses.hs), so acquire-org-premises returns the home study - the same seat
; the old C++ found_org used. The (head-runs-household @self) gate (the head's O(1)
; {@self employer <household-org>} -> articles lookup) flips true once founded, so
; this self-throttles to exactly one household per head. Servant hiring stays in
; the monthly ACT below (it now no-ops until the articles exist).
(hsim-event found_household
  (sim-window-start)
  (rng-stream employment)

  (roles
    (role @self (template any_human)))

  (when (and (>= (years-old @self) 21)                  ; non-belief age gate -> (when)
             (has-goal staff_household)                 ; head took the duty
             (not (head-runs-household @self))          ; not already founded
             (believes @self {@self home ?h})           ; BIND ?h = the home
             (believes @self {@self own ?h})            ; @self OWNS that home (the head)
             (or (is-a ?h [k manor]) (is-a ?h [k townhouse]))))

  (effects (found-org-seq [k org household] [k job head_of_household])))

; --- ACT: the head fulfils the duty - hires what the founded household lacks ---
(hsim-event staff_household
  ; PER-NPC (long-term-think): the household head fulfils his standing staffing
  ; duty once a month-window. The (generative-staffing) dispatch
  ; (run_generative_staffing -> begin_generative_actor) reads @self, GATES on the
  ; {@self goal {@self staff_household}} duty the think minted, then FILLS-TO-TARGET
  ; (hsim::staff_household hires the shortfall once found_household has constituted
  ; the org; no-ops while no articles exist and once full - self-throttles).
  (long-term-think)
  (rng-stream employment)
  (generative-staffing)

  (roles
    (role @self (template any_human)
                (believes {@self home ?})))

  (when (>= (years-old @self) 21)))   ; non-belief age gate -> (when)
