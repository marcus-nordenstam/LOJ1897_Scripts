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
