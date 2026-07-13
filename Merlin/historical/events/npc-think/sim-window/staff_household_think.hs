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
; The slow dispositional (window-start) pass, per NPC, fully declarative: a 21+
; adult who, IN WINTER and not already holding the duty, OWNS the manor / townhouse
; that is their HOME mints the standing goal {@self goal {@self staff_household}}.
; Tenants and co-resident spouses (home is a manor but they do not OWN it) never
; take it on. Clause order matters - the cheap gates short-circuit first so the
; is-a checks run only for winter, dutyless, home-owning candidates; and `?h` is
; BOUND by the first (believes) (the home), then reused to test ownership + kind.
(npc-think consider_household_staffing
  (sim-window-think)
  (rng-stream employment)

  (role @self (any_human @self))

  (when (and (>= (years-old @self) 21)                  ; non-belief age gate -> (when)
             (or (in-month 12) (in-month 1) (in-month 2)) ; winter, once a year
             (no-goal {@self staff_household})         ; mint once, then skip
             (believes @self {@self home ?h})          ; BIND ?h = the home
             (believes @self {@self own ?h})           ; @self OWNS that home (the head)
             (or (is-a ?h [k manor]) (is-a ?h [k townhouse]))))

  (cont-fire-effects (begin-goal {@self staff_household})))

; --- FOUND: the head constitutes the household org at his home study -----------
; A separate window-start pass (not season-gated, so it catches the standing duty
; whatever the event load order): a head who holds the staffing duty, OWNS the
; manor / townhouse that is his HOME, and does NOT yet run a household founds the
; `org household` via the shared found-org-seq macro. household is residence-seated
; (businesses.hs), so acquire-org-premises returns the home study - the same seat
; the old C++ found_org used. The self-throttle gate is the head's own O(1)
; {@self employer [k org household]} self-belief (a household seat he heads); the
; kind criterion matches the employer target's org-object kind by is-a, so it flips
; true once founded and this self-throttles to exactly one household per head.
; Servant hiring stays in the monthly ACT below (it no-ops until the articles exist).
(npc-think found_household
  (sim-window-think)
  (goal {@self staff_household})
  (rng-stream employment)

  (role @self (any_human @self))

  (when (and (>= (years-old @self) 21)                  ; non-belief age gate -> (when)
             (believes @self {@self home ?h})           ; BIND ?h = the home
             (believes @self {@self own ?h})            ; @self OWNS that home (the head)
             (or (is-a ?h [k manor]) (is-a ?h [k townhouse]))
             (not (believes {@self employer [k org household]}))))

  (cont-fire-effects (found-org-seq [k org household] [k job head_of_household])))

; --- ACT: the head fulfils the duty - hires what the founded household lacks ---
(npc-think staff_household
  ; PER-NPC (sim-window-think): the household head fulfils his standing staffing
  ; duty once a month-window. PURE .hs: the gate is the duty the think minted
  ; plus ownership of the home (a co-resident spouse / tenant staffs nothing);
  ; (staff-household ?h) then FILLS-TO-TARGET (hsim::staff_household hires the
  ; shortfall once found_household has constituted the org; no-ops while no
  ; articles exist and once full - self-throttles).
  (sim-window-think)
  (goal {@self staff_household})
  (rng-stream employment)

  (role @self (any_human @self)
              (believes {@self home ?}))

  (when (and (>= (years-old @self) 21)                  ; non-belief age gate -> (when)
             (believes @self {@self home ?h})           ; BIND ?h = the home
             (believes @self {@self own ?h})))          ; @self OWNS it (the head)

  (cont-fire-effects (staff-household ?h
             /slots   household_staff_slots
             /age-min (staff_hire_age_min)
             /age-max (staff_hire_age_max))))
