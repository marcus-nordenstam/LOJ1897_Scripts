; ----------------------------------------------------------------------------
; signals.hs - (signal ...) dimension + (classify ...) classifier declarations
; for the derived-signals engine (Merlin docs/derived_signals_program.md;
; loaded by hsim::signals_load at ontology-load time).
;
; A SIGNAL is a continuous, per-mind, per-object FELT scalar (the stance
; family), nudged by engine couplings and leaked per tick - never by act
; records (judgments recoverable from the belief record are (evidence ...)
; folds evaluated at read time; dispositions with no fluent bump stream are
; banded beliefs with event-driven transitions).
;
; A CLASSIFY declaration derives from an expression over signals / attrs /
; beliefs:
;   Shape A: (from <expr>) + (bands ([k <kind>] <min>) ...)  - band-kind mint
;   Shape B: (kind [k <kind>]) + (when <expr>)               - boolean toggle
;   Shape V: (value) + (from <expr>)   - NOTHING minted; evaluated on demand
;            via (classifier-value <label>) / the engine read seam
;   Shape M: (argmax ([k <kind>] <e>) ... (floor <min> [k <fb>])) - dominant
;            kind, prior ended on change ((core-episode) preserves history)
; (def <name> <expr>) names a shared sub-expression. Band boundaries carry
; hysteresis (the engine dead-band); a band with min -1 is the floor band.
; ----------------------------------------------------------------------------

; ----------------------------------------------------------------------------
; Shared sub-expressions.
; ----------------------------------------------------------------------------

; observance - recency-weighted worship-episode evidence mass (0..1). A
; read-time fold over the subject's OWN worship memories: forgetting the
; episodes honestly degrades the judgment, and the same fold about ANOTHER
; person uses only the episodes the observer holds - the church-going
; pretender fools it by design (practice, not faith; inner faith is a banded
; belief with event-driven transitions - future work). A monthly churchgoer
; saturates; a quarterly attender reads ~0.5; a 2-year lapse fades out.
(def observance (evidence worship (half-life 6) (saturate 6)))

; piety01 - observance mapped onto the historical piety anchors: 0.25 the
; never-worships floor, 0.85 the regular-churchgoer ceiling.
(def piety01 (clamp (sum 0.25 (scale observance 0.60)) 0 1))

; visible-sobriety - the PUBLIC reading of the drinking habit: below the 0.70
; visibility threshold, each trapping of respectability conceals (not a pub
; regular 0.25, employer 0.20, spouse 0.15, wealth >= 0.65 adds 0.20). A
; theory-of-mind stand-in (what the parish can see) used ONLY by repute;
; dissolves when abduction v2 makes repute per-observer.
(def visible-sobriety
  (clamp (sum (dim sobriety)
              (product (inv (ge (dim sobriety) 0.70))
                       (sum (scale (inv (act-at indulge [k building pub])) 0.25)
                            (scale (present employer) 0.20)
                            (scale (present spouse) 0.15)
                            (scale (ge (dim wealth) 0.65) 0.20)))) 0 1))

; reputed-chastity01 - the chastity_repute band mapped back to its scalar
; rungs: spotless 0.85 (no leaked liaison), tarnished 0.55 (one), disgraced
; 0.25 (two or more).
(def reputed-chastity01
  (sum (scale (has reputed_chastity [k chastity_repute spotless])  0.85)
       (scale (has reputed_chastity [k chastity_repute tarnished]) 0.55)
       (scale (has reputed_chastity [k chastity_repute disgraced]) 0.25)))

; piety - Shape V (value-only, NOTHING minted): the dimension consumers -
; (classifier-value piety) in .hs gates, deliberation dim rows, the
; not-yet-ported C++ fuses - evaluate this on demand.
(classify piety (value) (from piety01))

; devoutness - the OBSERVANCE reading: recency-weighted worship-episode
; evidence, banded to the piety_band kinds. (evidence ...) is a read-time
; fold over the subject's OWN worship memories - forgetting the episodes
; honestly degrades the judgment, and the same fold read about ANOTHER
; person uses only the episodes the observer holds (witnessed / heard), so
; the church-going pretender fools it by design. This is practice, not
; faith: inner faith is a banded belief with event-driven transitions
; (upbringing seed, bereavement / conversion events - future work).
; Tuning: a monthly churchgoer's mass ~ 9 (sum of 0.5^(k/6) over recent
; services) -> saturates devout; a quarterly attender ~ 3 -> observant; a
;2-year lapse decays through observant to secular as the memories age and
; fade. The floor band (secular, min -1) means every NPC carries a reading.
(classify devoutness
  (from observance)
  (bands ([k piety_band devout]    0.55)
         ([k piety_band observant] 0.15)
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


; respectability_situation - the TRUE-character fuse: the mean of the seven
; conduct dimensions with RAW sobriety and TRUE chastity (ruling C1: what is
; true of the conduct, not what the parish can see - the functioning
; alcoholic reads low here while his repute stays high; the gap is the
; blackmail stake).
(classify respectability_situation
  (from (mean (dim honesty)
              (dim sobriety)
              piety01
              (dim diligence)
              (dim chastity)
              (dim decorum)
              (dim generosity)))
  (bands ([k respectability_situation exemplary]    0.80)
         ([k respectability_situation respectable]  0.60)
         ([k respectability_situation questionable] 0.40)
         ([k respectability_situation disreputable] 0.20)
         ([k respectability_situation scandalous]   -1)))

; repute - the PUBLIC-estimate fuse: visible sobriety + the leaked chastity
; band in place of the true dimensions. A transitional theory-of-mind
; stand-in (the subject models what the town can know) until abduction v2
; makes reputation genuinely per-observer.
(classify repute
  (from (mean (dim honesty)
              visible-sobriety
              piety01
              (dim diligence)
              reputed-chastity01
              (dim decorum)
              (dim generosity)))
  (bands ([k respectability_situation exemplary]    0.80)
         ([k respectability_situation respectable]  0.60)
         ([k respectability_situation questionable] 0.40)
         ([k respectability_situation disreputable] 0.20)
         ([k respectability_situation scandalous]   -1)))

; inhibition - Shape V (value-only): the moral / conscientious brake on
; pressure-driven impulse, evaluated on demand by deliberation, the
; (classifier-value inhibition) gates and the coward identity clause.
; Weights are the historical situations.hs values on the 0..1 scale; the
; dark-tetrad terms apply above the population mean only (the one-sided
; amplification convention); held values steady the brake, rationalising
; justifications erode it.
(classify inhibition (value)
  (from (clamp (sum (sum (scale (attr politeness)      0.30)
                         (scale (attr industriousness) 0.30)
                         (scale (attr compassion)      0.15)
                         (scale piety01                0.20)
                         (scale (dim decorum)          0.10)
                         (scale (dim disinhibition)   -0.20)
                         (scale (dim stress 0)        -0.30))
                    (sum (scale (clamp (sum (attr narcissism)       -0.5) 0 1) -0.10)
                         (scale (clamp (sum (attr machiavellianism) -0.5) 0 1) -0.15)
                         (scale (clamp (sum (attr psychopathy)      -0.5) 0 1) -0.20)
                         (scale (clamp (sum (attr sadism)           -0.5) 0 1) -0.25)
                         (scale (count value)    0.05)
                         (scale (count justify) -0.08))) 0 1)))

; life_aim - the dominant of the seven aims (argmax over multiplicative
; composites; the floor keeps a featureless NPC wanting to belong somewhere).
; Non-@excl label: the emitter ends the prior dominant aim on a qualitative
; shift and (core-episode) preserves the multi-decade interval history
; through semantic compression.
(classify life_aim
  (core-episode)
  (argmax
    ([k life_aim legacy_aim]
       (product (mean (attr compassion) (attr politeness))
                (sum 0.3 (scale (present child) 0.7))
                (sum 0.3 (scale (clamp (sum (has class_situation [k class_situation upper])
                                            (has class_situation [k class_situation middle])) 0 1) 0.7))))
    ([k life_aim wealth_aim]
       (product (attr industriousness)
                (inv piety01)
                (max (inv (dim wealth))
                     (has social_trajectory [k social_trajectory rising]))))
    ([k life_aim piety_aim]
       (product piety01
                (inv (dim criminality))
                (sum 0.4 (scale (act-at worship [k building church]) 0.6))))
    ([k life_aim respectability_aim]
       (product (attr politeness)
                piety01
                (sum 0.2 (scale (has class_situation [k class_situation middle]) 0.8))
                (dim decorum)))
    ([k life_aim autonomy_aim]
       (product (attr assertiveness) (inv (dim rootedness))))
    ([k life_aim power_aim]
       (product (attr machiavellianism)
                (attr narcissism)
                (sum 0.3 (scale (present employer) 0.7))))
    ([k life_aim belonging_aim]
       (product (attr enthusiasm)
                (inv (dim rootedness))
                (clamp (scale (count friend) 0.2) 0 1)))
    (floor 0.01 [k life_aim belonging_aim])))
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
