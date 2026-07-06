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

; Live crowding ratio: alive-count / target. 1.0 at carrying capacity, < 1 when
; sparse, > 1 when crowded. The per-NPC emigration think scales each young
; adult's monthly leave-chance by it, so crowding raises the outflow and a sparse
; parish (immigration territory) sheds almost no one. Replaces the old
; homeostat_emigration "emigrate the oldest N by fiat" world valve.
(define-macro population-pressure () (/ (alive-count) (homeostat_target_population)))

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
