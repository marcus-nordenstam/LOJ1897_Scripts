; ----------------------------------------------------------------------------
; tunables.hs - shared curves + tunable constants, as macros.
;
; These were formerly (define-table ...) + (table-lookup ...) named expressions; they
; are just named formulas / constants, so they are macros now. A curve takes its
; input as a real parameter; a constant takes none. Edit once, re-tunes every
; rule that calls it.
; ----------------------------------------------------------------------------

; Background per-year mortality curve: integer years-of-age -> death probability.
; Folds in pre-industrial infant + child mortality at the low end.
(define-macro mortality_by_age (?age)
  (if (< ?age 15) (then 0.006)
  (else (if (< ?age 40) (then 0.005)
  (else (if (< ?age 55) (then 0.010)
  (else (if (< ?age 65) (then 0.022)
  (else (if (< ?age 75) (then 0.050)
  (else (if (< ?age 85) (then 0.110)
  (else (if (< ?age 95) (then 0.220)
  (else 1.000)))))))))))))))

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

; The monthly base rate a LAWFUL grievance outlet (confess / report) rolls at, before
; its own base weight and the actor's drive. The unlawful outlets use (crime-scale)
; instead - this is its lawful twin, kept at the same magnitude so a lawful and an
; unlawful response to the same grievance stay comparable.
(define-macro k-grievance-rate () 0.1)

; Grievance tilt swings: how far one dimension at 0 or 1 moves its category
; multiplier off the 1.0 baseline. Trait is dispositional (larger), mood transient
; (smaller); each held rationalisation adds k-justify-per to the (1 + discount) wrap.
(define-macro k-trait-swing () 0.2)
(define-macro k-mood-swing  () 0.15)
(define-macro k-justify-per () 0.1)

; Routine-drive tilt swings (worship / work). Larger than the crime buckets': a
; drive lane carries ONE or TWO trait rows, so each needs a wider spread to give
; the diligent-vs-shirker / devout-vs-lax spread off a single trait.
(define-macro k-drive-trait-swing () 0.6)
(define-macro k-drive-mood-swing  () 0.3)

; Suicide despair gate: the act fires only when despair (= stress x (1 - contentment))
; and withdrawal both clear these floors; the witnessed ideation is minted regardless.
(define-macro suicide_despair_min    () 0.40)
(define-macro suicide_withdrawal_min () 0.55)
; The loot-worth floor (coin price, ontology (price N)): burgle picks, and stow hides in a
; fashioned spot, only items priced ABOVE this. Replaces the old boolean `valuable` facet -
; behaviour keys on a real price now, not a vague tag.
(define-macro valuable_loot_price_min () 5)

; The practice-marker window (days) the strive outlet stamps; read by skill atrophy.
(define-macro skill_practice_window_days () 548)
; find-building's `surveyed` private-bb marker lifetime, in hsim cycles (= months).
; Long enough for one coverage sweep to complete without re-surveying; short enough
; that a searcher's markers self-reclaim within a year of the search ending.
(define-macro survey_marker_ttl_cycles () 12)

; buy-home's public-bb `claimed` marker lifetime, in hsim cycles (= months). A buyer
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

; One immigrant wave: ?count arrivals, each a full human minted by the shared
; make-human func into a residence that will take them. The authored knobs above
; shape who arrives; the row data (ranks / origins / marginal jobs) lives in
; tables/immigrant-tables.hs and is read where those beliefs are minted, not here.
(define-macro spawn-immigrant-wave (?count)
  (repeat ?count
    (head (env-entities [k building rowhouse])): ?imm-home
    (if (substantial ?imm-home)
      (then
        (make-human ?imm-home [k class-situation lower])))))

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

; THRESHOLD GEOMETRY (was C++ front_park_point / at_threshold). An actor approaching a
; venue stands off its front face by its own forward half-extent times this clearance,
; so a wider body stands proportionally further back. front-park-point (funcs/spatial.mc)
; is the whole formula.
(define-macro front_park_clearance     () 1.0)
; How close to that stand-off point counts as AT the threshold. The "not inside the
; venue" guard does the real work, so the exact band is not critical.
(define-macro at_threshold_band_m      () 1.5)

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
