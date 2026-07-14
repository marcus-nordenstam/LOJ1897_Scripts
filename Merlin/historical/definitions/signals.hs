; ----------------------------------------------------------------------------
; signals.hs - (signal ...) dimension + (classify ...) classifier declarations
; for the derived-signals engine (Merlin docs/derived_signals_program.md;
; loaded by hsim::signals_load at ontology-load time).
;
; A SIGNAL is a continuous, per-mind, per-object scalar: bumped by belief
; commits (a (bump <label> <delta>) rule fires on every commit under that
; label, nudging the SUBJECT's row - own acts accrue own dimensions, witnessed
; acts accrue the observer's estimate of the actor), and leaked once per
; monthly tick by (leak <retention>). Signals never mint float beliefs - only
; the thresholded BANDS below reach the belief layer.
;
; A CLASSIFY declaration emits a discrete belief from an expression over
; signals / attrs / beliefs:
;   Shape A: (from <expr>) + (bands ([k <kind>] <min>) ...)  - band-kind mint
;   Shape B: (kind [k <kind>]) + (when <expr>)               - boolean toggle
; Band boundaries carry hysteresis (the engine's dead-band), so a value
; wobbling on a threshold never thrashes the belief. A band with min -1 is
; the floor band (always entered when nothing stronger holds).
; ----------------------------------------------------------------------------

; piety - the lived-devoutness accumulator (the derived-signals pilot).
; Each committed {X worship <church>} act-record bumps X's piety by 0.15 in
; the committing mind; the signal retains 0.94 per monthly tick. A monthly+
; churchgoer saturates toward 1.0; a lapsed one halves in ~11 months.
(signal piety (range unsigned) (leak 0.94) (bump worship 0.15))

; devoutness - the piety signal banded to the piety_band kinds. The floor
; band (secular, min -1) means every NPC carries a devoutness reading, the
; way every NPC carries an economic_situation.
(classify devoutness
  (from (signal piety))
  (bands ([k piety_band devout]    0.55)
         ([k piety_band observant] 0.18)
         ([k piety_band secular]   -1)))

; ----------------------------------------------------------------------------
; Situation fusions (Shape A bands) - ported from hsim_derive's C++ folds.
; Each reads the float dimension beliefs the annual derive pass mints
; ((dim ...) inputs; a subject without them - children, fresh spawns - skips
; and keeps its seeded classification). derive_prototypes runs this catalog
; INLINE right after the dims mint, so its in-pass consumers (scarcity seed,
; for_hire, life_satisfaction) read fresh bands; the monthly emit keeps them
; current between derive passes. DECLARATION ORDER IS EVALUATION ORDER:
; situations must precede the prototypes that read them.
; (respectability_situation / repute stay C++ - they fuse the transient
; concealment-adjusted visible_sobriety.)
; ----------------------------------------------------------------------------

; economic_situation <- the wealth dimension. Band mins are the old ascending
; upper bounds (15/30/45/60/75/90 on the 0..100 scale) read as descending
; entry thresholds on the 0..1 dimension.
(classify economic_situation
  (from (dim wealth))
  (bands ([k economic_situation wealthy]     0.90)
         ([k economic_situation prosperous]  0.75)
         ([k economic_situation comfortable] 0.60)
         ([k economic_situation stable]      0.45)
         ([k economic_situation struggling]  0.30)
         ([k economic_situation poor]        0.15)
         ([k economic_situation destitute]   -1)))

; class_situation <- breeding (the dominant lineage anchor) + prestige (public
; office) + wealth, weights 5/3/2 normalized. A high prestige + wealth can
; carry a low-breeding man up a band - the self-made climb; idle high breeding
; alone slides down.
(classify class_situation
  (from (weighted-sum (0.5 (dim breeding))
                      (0.3 (dim prestige))
                      (0.2 (dim wealth))))
  (bands ([k class_situation upper]  0.70)
         ([k class_situation middle] 0.40)
         ([k class_situation lower]  -1)))

; social_trajectory <- the divergence of achieved standing ((prestige +
; wealth) / 2) from the inherited breeding anchor; +/- 0.15 counts as a move.
; The climbing clerk reads rising; the idle high-breeding heir declining.
(classify social_trajectory
  (from (sum (scale (dim prestige) 0.5)
             (scale (dim wealth)   0.5)
             (scale (dim breeding) -1)))
  (bands ([k social_trajectory rising]    0.15)
         ([k social_trajectory stable]    -0.15)
         ([k social_trajectory declining] -2)))

; ----------------------------------------------------------------------------
; Prototypes (Shape B toggles) - named conjunctions over the situations /
; dimensions, ported from hsim_derive's C++ predicates. Each reads the
; situation BAND beliefs and float dimension beliefs the annual derive pass
; mints; a subject the cascade has not derived yet (children, fresh spawns)
; holds its (dim ...) inputs absent, so the classifier skips and the
; classification waits for the first derive - same admission rule as the old
; annual pass. Booleans compose as products of (ge/le/has) 0-or-1 terms;
; OR = (clamp (sum ...) 0 1).
; ----------------------------------------------------------------------------

; drunkard: a standing craving for drink IS the dependency.
(classify prototype
  (kind [k prototype drunkard])
  (when (present craving)))

; nouveau_riche: high wealth (>= 0.60) carried by low breeding (<= 0.35) -
; new money, not old blood. Thresholds mirror situations.hs prototype-tuning.
(classify prototype
  (kind [k prototype nouveau_riche])
  (when (product (ge (dim wealth) 0.60)
                 (le (dim breeding) 0.35))))

; self_made_man: a low-born man risen into the middle class or above on a
; sound character - rising trajectory + arrived class + low breeding +
; reputable standing.
(classify prototype
  (kind [k prototype self_made_man])
  (when (product (has social_trajectory [k social_trajectory rising])
                 (clamp (sum (has class_situation [k class_situation middle])
                             (has class_situation [k class_situation upper])) 0 1)
                 (le (dim breeding) 0.40)
                 (clamp (sum (has respectability_situation [k respectability_situation exemplary])
                             (has respectability_situation [k respectability_situation respectable])) 0 1))))

; deserving_poor / undeserving_poor: the shared economic test (poor or
; destitute), split on respectability.
(classify prototype
  (kind [k prototype deserving_poor])
  (when (product (clamp (sum (has economic_situation [k economic_situation poor])
                             (has economic_situation [k economic_situation destitute])) 0 1)
                 (clamp (sum (has respectability_situation [k respectability_situation exemplary])
                             (has respectability_situation [k respectability_situation respectable])) 0 1))))

(classify prototype
  (kind [k prototype undeserving_poor])
  (when (product (clamp (sum (has economic_situation [k economic_situation poor])
                             (has economic_situation [k economic_situation destitute])) 0 1)
                 (clamp (sum (has respectability_situation [k respectability_situation disreputable])
                             (has respectability_situation [k respectability_situation scandalous])) 0 1))))
