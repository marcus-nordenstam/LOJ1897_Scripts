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
