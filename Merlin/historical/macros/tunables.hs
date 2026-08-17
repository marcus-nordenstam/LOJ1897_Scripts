; ----------------------------------------------------------------------------
; tunables.hs - shared curves + tunable constants, as macros.
;
; These were formerly (define-table ...) + (lookup ...) named expressions; they
; are just named formulas / constants, so they are macros now. A curve takes its
; input as a real parameter; a constant takes none. Edit once, re-tunes every
; event that calls it.
; ----------------------------------------------------------------------------

; Background per-year mortality curve: integer years-of-age -> death probability.
; Folds in pre-industrial infant + child mortality at the low end.
(define-macro mortality_by_age (?age)
  (age-bracket ?age
    ((<  15)  0.006)
    ((<  40)  0.005)
    ((<  55)  0.010)
    ((<  65)  0.022)
    ((<  75)  0.050)
    ((<  85)  0.110)
    ((<  95)  0.220)
    (else     1.000)))

; Population homeostat tunables (constants). target_population is the carrying
; capacity both the per-NPC emigration (population-pressure) and the sparse-side
; immigration valve steer toward. The emigration count/pressure knobs were retired
; with the homeostat_emigration world valve - outflow is now per-NPC and organic.
(define-macro homeostat_target_population   () 200.0)
(define-macro homeostat_immigration_pressure () 0.90)
(define-macro homeostat_immigration_count   () 6)

; Live crowding ratio: living-npc-count / target. 1.0 at carrying capacity, < 1 when
; sparse, > 1 when crowded. The per-NPC emigration think scales each young
; adult's monthly leave-chance by it, so crowding raises the outflow and a sparse
; parish (immigration territory) sheds almost no one. Replaces the old
; homeostat_emigration "emigrate the oldest N by fiat" world valve.
(define-macro population-pressure () (/ (living-npc-count) (homeostat_target_population)))

; Labour market: the wealth ceiling above which an NPC does NOT seek waged work (the
; independently wealthy). Wealth is the {@self wealth ?w} belief (~0..1.25, balance/120);
; only the genuinely rich clear this bar. A seeker with no wealth belief yet is treated
; as needing work (the gate defaults them in).
(define-macro seek_job_wealth_ceiling () 1.0)

; Deliberation inaction floor: the fixed weight of "forgive / do nothing" in the
; act-vs-floor pick that follows the (select-joint ...) deliberation. The winner's
; pressure-driven action score competes against this ONCE per fire, so a weak
; pressure resolves to inaction and a strong one acts. Replaces the old per-branch
; C++ floor rows + identity anchor.
(define-macro deliberation_inaction_floor () 0.55)

; Suicide despair gate: the act fires only when despair (= stress x (1 - contentment))
; and withdrawal both clear these floors; the witnessed ideation is minted regardless.
(define-macro suicide_despair_min    () 0.40)
(define-macro suicide_withdrawal_min () 0.55)
; The practice-marker window (days) the strive outlet stamps; read by skill atrophy.
(define-macro skill_practice_window_days () 548)
; find_building's `surveyed` private-bb marker lifetime, in hsim cycles (= months).
; Long enough for one coverage sweep to complete without re-surveying; short enough
; that a searcher's markers self-reclaim within a year of the search ending.
(define-macro survey_marker_ttl_cycles () 12)

; buy_home's public-bb `claimed` marker lifetime, in hsim cycles (= months). A buyer
; posts it on the dwelling he commits to (choose_home) so a rival seeker in the same
; window defers. choose_home cont-fires and RE-POSTS the claim every cycle the buyer
; stays committed, so the ttl only bounds how fast an ABANDONED claim self-clears once
; he stops (bought the dwelling and destroyed its listing, or lost the motor). 3 cycles
; comfortably bridges the one-cycle gap from selection to buy_home_act destroying the
; listing, and frees an abandoned claim within a season so a rival is not blocked for
; the rest of the march buying window.
(define-macro claim_marker_ttl_cycles () 3)

; Covert-letter channel model (route-covert-letter's authored knobs; composed
; by send-covert-letter in affair_macros.hs). Channel weights are relative -
; the courier needs the sender's own staff, poste-restante needs standing, so
; either may zero out at routing time and the rest renormalize.
(define-macro covert_w_courier          () 0.35)
(define-macro covert_w_post             () 0.45)
(define-macro covert_w_poste            () 0.20)
(define-macro covert_intercept_courier  () 0.10)  ; the carrying servant reads it
(define-macro covert_intercept_post     () 0.06)  ; recipient household mail-handler
(define-macro covert_dislike_gain       () 1.5)   ; x per negative warmth band
(define-macro covert_suspicion_gain     () 1.0)   ; passive-roll multiplier per unit
(define-macro covert_intercept_cap      () 0.5)
(define-macro covert_handling_suspicion () 0.06)  ; a strange hand on the post, again

; The immigrant-wave model (spawn-immigrant's authored knobs; the row data -
; ranks / origins / marginal jobs - lives in tables/immigrant_tables.hs).
(define-macro immigrant_female_frac        () 0.5)
(define-macro immigrant_marginal_frac      () 0.30)  ; arrive socially invisible
(define-macro immigrant_military_frac      () 0.20)  ; of MALE immigrants
(define-macro immigrant_still_serving_frac () 0.20)  ; of those, still in uniform
(define-macro immigrant_swordsman_frac     () 0.25)  ; blade vs musket
(define-macro immigrant_age_min            () 18)
(define-macro immigrant_age_max            () 32)

; One immigrant wave with the full authored model - the ONE way content
; should call the spawn verb (no C++ defaults).
(define-macro spawn-immigrant-wave (?count)
  (spawn-immigrant ?count
    /female-frac        (immigrant_female_frac)
    /marginal-frac      (immigrant_marginal_frac)
    /military-frac      (immigrant_military_frac)
    /still-serving-frac (immigrant_still_serving_frac)
    /swordsman-frac     (immigrant_swordsman_frac)
    /age-min            (immigrant_age_min)
    /age-max            (immigrant_age_max)
    /class              lower
    /ranks              immigrant_ranks
    /origins            immigrant_origins
    /marginal-jobs      immigrant_marginal_jobs))

; Household staffing hire-age window (the staff slots themselves live in
; tables/household_staff.hs).
(define-macro staff_hire_age_min () 16)
(define-macro staff_hire_age_max () 55)

; Sporting-meet model (the per-sport rows live in tables/club_sports.hs).
(define-macro jockey_hire_age_min      () 16)
(define-macro jockey_hire_age_max      () 45)
(define-macro trained_victory_weight   () 3.0)  ; practice marker's edge in the victor roll
(define-macro training_window_days     () 365)

; Minimum minutes a `go` act occupies, even for a ~0-distance hop (a venue right next
; door, or a re-go to where you already stand). Floors the completion cadence so an NPC
; cannot re-deliberate every simulated minute - defense-in-depth against destination
; thrash. Small enough not to distort real travel; the real fix for "why re-go at all"
; is the arriving lane firing its purpose act (see at-place-kind).
(define-macro go_travel_floor_min      () 1)

; The household cook's public-bb claim lifetime, in hsim cycles (= months). The
; sitting cook RE-POSTS it every cycle (renew_cook), so the ttl only bounds how
; fast a DEAD or emigrated cook's household re-elects.
(define-macro cook_marker_ttl_cycles () 3)

; The kitchen-larder doctrine numbers, in PERSON-DAYS of food (1 prop = 1
; person-day; only a home supper consumes, so a 4-head household eats 4 per
; sim-day). Target 16 = ~4 sim-days; the low-water refill (a basket of 8) puts
; the cook at the counter every OTHER sim-day - pure count-driven cadence.
; larder_target MUST match weapon_seed.h k_home_starter_larder.
(define-macro larder_target    () 16)
(define-macro larder_low_water () 8)
; One basket: what the cook carries home in one trip. MUST stay under the
; hand's grip capacity (single-valued once bag-as-stack lands).
(define-macro carry_cap () 8)
