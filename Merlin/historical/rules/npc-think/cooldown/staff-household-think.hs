; ----------------------------------------------------------------------------
; staff_household.hs - domestic-service staffing of quality homes
; (see Docs/hsim/hsim_social.md "Households").
;
; PURE .hs, three passes: THINK (a quality-home owner takes on the standing
; staffing duty), FOUND (the head constitutes the `org household` seated AT
; the home - its employee_register doubles as the servants' wage book), and
; ACT (the head fills vacant roster slots via the (staff-household ?h)
; construction verb - manor: steward / cook / 2 maids / gardener; townhouse:
; cook / maid - from the jobless lower-class adult pool, acquainting each new
; servant with the head + spouse and seeding a temperament-fit warmth stance,
; the hostile-staff lever).
;
; The household is an ORDINARY org, so the establishment is inherited /
; dissolved with the rest of the estate by propagate_death, and servants are
; ordinary employees (fire / promote / job objects all apply). The staff are
; the interception / surveillance surface of the covert-affair plan (Phases
; 1 + 3) - and substrate for theft / witness / class-friction stories
; generally. Refills annually as servants die or move on.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; --- THINK: a quality-home OWNER takes on the standing staffing duty -----------
; The slow dispositional THINK, per NPC, fully declarative: a 21+
; adult who, IN WINTER and not already holding the duty, OWNS the manor / townhouse
; that is their HOME mints the standing goal {@self goal {@self staff_household}}.
; Tenants and co-resident spouses (home is a manor but they do not OWN it) never
; take it on. `?h` is a CACHED role: the object-cache membership test runs every
; filter against the SAME candidate, so home + own share one witness, and the
; `[k <kind>]:?h` kind-cast is identity AND is-a against the owned object's
; PERMANENT kind (never a decaying isa belief). Non-owners carry an empty set and
; skip the rule without any belief scan; only the non-belief date / age / goal
; gates stay live in (when).
(npc-think consider_household_staffing
  (cooldown 1 m)
  (rng-stream employment)

  (role @self )
  (role ?h {@self home ?h}
           (or {@self own [k manor]:?h}
               {@self own [k townhouse]:?h}))

  (when (and (>= (years-old @self) 21)                  ; non-belief age gate -> (when)
             (or (in-month 12) (in-month 1) (in-month 2)) ; winter, once a year
             (no-goal {@self staff_household})))        ; mint once, then skip

  (utility errand)
  (effects (begin-goal {@self staff_household})))

; --- FOUND: the head constitutes the household org at his home study -----------
; A separate THINK (not season-gated, so it catches the standing duty
; whatever the rule load order): a head who holds the staffing duty, OWNS the
; manor / townhouse that is his HOME, and does NOT yet run a household founds the
; `org household` via the shared found-org-seq macro. household is residence-seated
; (businesses.hs), so acquire-org-premises returns the home study - the same seat
; the old C++ found_org used. The self-throttle is the CACHED self-gate filter
; (none {@self job.org [k org household]}): the kind criterion matches
; the job.org target's org-object kind by is-a (the symbolic matcher's
; object-vs-kind, permanent - never the decaying {?org isa ...} belief), so it
; flips false once founded and this self-throttles to exactly one household per
; head, reconciled on job.org writes. `?h` is the same cached owned-quality-home
; role as the THINK above. Servant hiring stays in the monthly ACT below (it
; no-ops until the articles exist).
(npc-think found_household
  (cooldown 1 m)
  (goal {@self staff_household})
  (rng-stream employment)

  (role @self (not {@self job.org [k org household]}))
  (role ?h {@self home ?h}
           (or {@self own [k manor]:?h}
               {@self own [k townhouse]:?h}))

  (when (>= (years-old @self) 21))                      ; non-belief age gate -> (when)

  (effects (found-org-seq [k org household] [k job head_of_household])))

; --- ACT: the head fulfils the duty - hires what the founded household lacks ---
(npc-think staff_household
  ; PER-NPC (cooldown 1 m): the household head fulfils his standing staffing
  ; duty once a month. PURE .hs: the gate is the duty the think minted
  ; plus ownership of the home (a co-resident spouse / tenant staffs nothing).
  ; `?h` is a CACHED role - home + own tested against the SAME candidate, and the
  ; role BINDS ?h for the effect. (staff-household ?h) then FILLS-TO-TARGET
  ; (hsim::staff_household hires the shortfall once found_household has
  ; constituted the org; no-ops while no articles exist and once full -
  ; self-throttles).
  (cooldown 1 m)
  (goal {@self staff_household})
  (rng-stream employment)

  (role @self )
  (role ?h {@self home ?h}
           {@self own ?h})

  ; Winter-only so the bout CEASES each spring and re-arms: a think-act whose (when)
  ; stays true holds forever and fires exactly once (never refilling). Pulsing the
  ; gate makes it re-attempt every winter as servants die or the labour pool refills.
  (when (and (>= (years-old @self) 21)
             (or (in-month 12) (in-month 1) (in-month 2))))

  (effects (staff-household ?h
             /slots   household_staff_slots
             /age-min (staff_hire_age_min)
             /age-max (staff_hire_age_max))))
