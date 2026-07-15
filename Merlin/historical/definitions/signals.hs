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
;
; The <expr> in every (from ...) / (when ...) / argmax arm is an ORDINARY .hs
; expression, compiled by the ONE shared parser and evaluated by the shared
; combinators (+ - * / >= <= min max clamp) PLUS the classifier belief reads
; (signal / dim / attr / count / count-ever / present / has / evidence /
; act-at). Boolean predicates compose arithmetically: AND = (* a b ...),
; OR = (clamp (+ a b ...) 0 1), each (>= / <= / has / present) a 0-or-1 term.
; ----------------------------------------------------------------------------

; ----------------------------------------------------------------------------
; Impression map (abduction v2). An event that emits a witnessed episode
; (incident-anchor / witness-copresence) and gates its (chance ...) on
; (attr @self <trait>) reveals character to bystanders: witnessing the episode
; mints {actor seems <impression kind>} at the AUTHORED weight below. The
; gate's numeric constants are rate constants (how often the act fires), not
; evidence strengths, so the strength is authored per row. Inverted reads
; ((- 1 (attr ...))) and unmapped traits contribute nothing.
; ----------------------------------------------------------------------------

(impression volatility  [k impression hot_tempered] 0.6)
(impression psychopathy [k impression callous]      0.5)
(impression sadism      [k impression cruel]        0.5)
(impression narcissism  [k impression selfish]      0.4)

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
(def piety01 (clamp (+ 0.25 (* observance 0.60)) 0 1))

; visible-sobriety - the PUBLIC reading of the drinking habit: below the 0.70
; visibility threshold, each trapping of respectability conceals (not a pub
; regular 0.25, employer 0.20, spouse 0.15, wealth >= 0.65 adds 0.20). A
; theory-of-mind stand-in (what the parish can see) used ONLY by repute;
; dissolves when abduction v2 makes repute per-observer.
(def visible-sobriety
  (clamp (+ (dim sobriety)
            (* (- 1 (>= (dim sobriety) 0.70))
               (+ (* (- 1 (act-at drink [k building pub])) 0.25)
                  (* (present employer) 0.20)
                  (* (present spouse) 0.15)
                  (* (>= (dim wealth) 0.65) 0.20)))) 0 1))

; reputed-chastity01 - the chastity_repute band mapped back to its scalar
; rungs: spotless 0.85 (no leaked liaison), tarnished 0.55 (one), disgraced
; 0.25 (two or more).
(def reputed-chastity01
  (+ (* (has reputed_chastity [k chastity_repute spotless])  0.85)
     (* (has reputed_chastity [k chastity_repute tarnished]) 0.55)
     (* (has reputed_chastity [k chastity_repute disgraced]) 0.25)))

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
  (about others)
  (from observance)
  (bands ([k piety_band devout]    0.55)
         ([k piety_band observant] 0.15)
         ([k piety_band secular]   -1)))

; ----------------------------------------------------------------------------
; Conduct trait dimensions (Shape V value-only) - the temperamental priors the
; respectability / repute / inhibition fuses and the business/leisure gates
; read via (dim ...) / (classifier-value ...). Ported from hsim_derive's C++
; trait folds: a plain mean of the (possibly inverted) Big-Five / dark-tetrad
; aspects, read @self-only ((attr ...) is the mind's own entity). No float
; belief is minted; every reader evaluates the fold on demand.
; ----------------------------------------------------------------------------

; diligence - the industriousness aspect.
(classify diligence (value) (from (attr industriousness)))

; honesty - high politeness, low Machiavellianism (the dark-tetrad deceit trait).
(classify honesty (value)
  (from (/ (+ (attr politeness) (- 1 (attr machiavellianism))) 2)))

; disinhibition - the externalizing temperament: low industriousness, low
; politeness, high volatility.
(classify disinhibition (value)
  (from (/ (+ (- 1 (attr industriousness)) (- 1 (attr politeness)) (attr volatility)) 3)))

; aggression - the temperamental fold of high volatility, low politeness and
; dark-tetrad sadism.
(classify aggression (value)
  (from (/ (+ (attr volatility) (- 1 (attr politeness)) (attr sadism)) 3)))

; generosity - the compassion prior, lifted 0.20 by any recorded act of charity
; (an ended {@self give <alms>} act-record still counts - a lifetime tally).
(classify generosity (value)
  (from (clamp (+ (attr compassion) (* (>= (count-ever give) 1) 0.20)) 0 1)))

; criminality - a low base (0.05), raised 0.25 per recorded crime of ANY tense
; (assault / theft / fraud / embezzlement / homicide / kidnap - the act-records
; the crime pipeline writes). A single conviction reads middling; a habitual
; offender saturates.
(classify criminality (value)
  (from (clamp (+ 0.05
                  (* (+ (count-ever assault) (count-ever steal)
                        (count-ever defraud) (count-ever embezzle)
                        (count-ever kill)    (count-ever kidnap)) 0.25)) 0 1)))

; sobriety - the inverse of accumulated intoxication (an absent intoxication
; attr reads 0 = fully sober, NOT the 0.5 midpoint), hard-capped at 0.15 once a
; standing `craving` for drink has formed (a dependent drinker reads no higher
; however the attr stands), and further docked 0.25 x the gambling-addiction
; severity (intemperance compounds).
(def raw-sobriety (- 1 (attr intoxication 0)))
(classify sobriety (value)
  (from (clamp (+ (+ (* (- 1 (present craving)) raw-sobriety)
                     (* (present craving)       (min raw-sobriety 0.15)))
                  (* (attr gambling_addiction 0) -0.25)) 0 1)))

; ----------------------------------------------------------------------------
; Felt-life value classifiers (Shape V value-only) - ported from hsim_derive's
; C++ felt-life folds. No float belief minted; the (dim ...) readers fall
; through the linchpin and any C++ consumer evaluates on demand.
; ----------------------------------------------------------------------------

; rootedness - how established the NPC is in the community. Local lineage
; (mother / father), a spouse, children (each +0.06, capped at 4 = +0.24), a
; steady employer, owned property and club membership each add a partial score;
; the sum clamps to 1. A recently-arrived immigrant with just an employer reads
; low (~0.20); a settled local family - parents + spouse + children + employer -
; reads high. Weights are the historical situations.hs rootedness-* points on
; the 0..1 scale.
(classify rootedness (value)
  (from (clamp (+ (* 0.15 (present mother))
                  (* 0.15 (present father))
                  (* 0.20 (present spouse))
                  (* 0.06 (min (count child) 4))
                  (* 0.20 (present employer))
                  (* 0.15 (>= (count building) 1))
                  (* 0.10 (>= (count member_of) 1))) 0 1)))

; belonging - how well the NPC's warmth bonds + immediate kin meet its
; sociability need. Warmth = friends (close_to / friend) + kin (spouse x2,
; children capped at 5, parents capped at 2, siblings capped at 4). The need is
; 1 + Extraversion x 5, Extraversion = the mean of enthusiasm + assertiveness.
; belonging falls 0.18 per unit of unmet need (desired - warmth): an introvert
; with few bonds still reads content, an extravert with the same bonds starves.
(def belonging-warmth
  (+ (count close_to) (count friend)
     (* 2 (present spouse))
     (min (count child) 5)
     (min (+ (count mother) (count father)) 2)
     (min (+ (count sibling) (count half_sibling)) 4)))
(def belonging-sociability (* (+ (attr enthusiasm) (attr assertiveness)) 0.5))
(def belonging-desired (+ 1 (round (* belonging-sociability 5))))
(classify belonging (value)
  (from (clamp (- 1 (* (max (- belonging-desired belonging-warmth) 0) 0.18)) 0 1)))

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
  (from (+ (* 0.5 (dim breeding))
           (* 0.3 (dim prestige))
           (* 0.2 (dim wealth))))
  (bands ([k class_situation upper]  0.70)
         ([k class_situation middle] 0.40)
         ([k class_situation lower]  -1)))

; social_trajectory <- the divergence of achieved standing ((prestige +
; wealth) / 2) from the inherited breeding anchor; +/- 0.15 counts as a move.
; The climbing clerk reads rising; the idle high-breeding heir declining.
(classify social_trajectory
  (from (+ (* (dim prestige) 0.5)
           (* (dim wealth)   0.5)
           (* (dim breeding) -1)))
  (bands ([k social_trajectory rising]    0.15)
         ([k social_trajectory stable]    -0.15)
         ([k social_trajectory declining] -2)))


; respectability_situation - the TRUE-character fuse: the mean of the seven
; conduct dimensions with RAW sobriety and TRUE chastity (ruling C1: what is
; true of the conduct, not what the parish can see - the functioning
; alcoholic reads low here while his repute stays high; the gap is the
; blackmail stake).
(classify respectability_situation
  (from (/ (+ (dim honesty)
              (dim sobriety)
              piety01
              (dim diligence)
              (dim chastity)
              (dim decorum)
              (dim generosity)) 7))
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
  (from (/ (+ (dim honesty)
              visible-sobriety
              piety01
              (dim diligence)
              reputed-chastity01
              (dim decorum)
              (dim generosity)) 7))
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
  (from (clamp (+ (+ (* (attr politeness)      0.30)
                     (* (attr industriousness) 0.30)
                     (* (attr compassion)      0.15)
                     (* piety01                0.20)
                     (* (dim decorum)          0.10)
                     (* (dim disinhibition)   -0.20)
                     (* (dim stress 0)        -0.30))
                  (+ (* (clamp (+ (attr narcissism)       -0.5) 0 1) -0.10)
                     (* (clamp (+ (attr machiavellianism) -0.5) 0 1) -0.15)
                     (* (clamp (+ (attr psychopathy)      -0.5) 0 1) -0.20)
                     (* (clamp (+ (attr sadism)           -0.5) 0 1) -0.25)
                     (* (count value)    0.05)
                     (* (count justify) -0.08))) 0 1)))

; life_aim - the dominant of the seven aims (argmax over multiplicative
; composites; the floor keeps a featureless NPC wanting to belong somewhere).
; Non-@excl label: the emitter ends the prior dominant aim on a qualitative
; shift and (core-episode) preserves the multi-decade interval history
; through semantic compression.
(classify life_aim
  (core-episode)
  (argmax
    ([k life_aim legacy_aim]
       (* (/ (+ (attr compassion) (attr politeness)) 2)
          (+ 0.3 (* (present child) 0.7))
          (+ 0.3 (* (clamp (+ (has class_situation [k class_situation upper])
                              (has class_situation [k class_situation middle])) 0 1) 0.7))))
    ([k life_aim wealth_aim]
       (* (attr industriousness)
          (- 1 piety01)
          (max (- 1 (dim wealth))
               (has social_trajectory [k social_trajectory rising]))))
    ([k life_aim piety_aim]
       (* piety01
          (- 1 (dim criminality))
          (+ 0.4 (* (act-at worship [k building church]) 0.6))))
    ([k life_aim respectability_aim]
       (* (attr politeness)
          piety01
          (+ 0.2 (* (has class_situation [k class_situation middle]) 0.8))
          (dim decorum)))
    ([k life_aim autonomy_aim]
       (* (attr assertiveness) (- 1 (dim rootedness))))
    ([k life_aim power_aim]
       (* (attr machiavellianism)
          (attr narcissism)
          (+ 0.3 (* (present employer) 0.7))))
    ([k life_aim belonging_aim]
       (* (attr enthusiasm)
          (- 1 (dim rootedness))
          (clamp (* (count friend) 0.2) 0 1)))
    (floor 0.01 [k life_aim belonging_aim])))
; ----------------------------------------------------------------------------
; Prototypes (Shape B toggles) - named conjunctions over the situations /
; dimensions, ported from hsim_derive's C++ predicates. Each reads the
; situation BAND beliefs and float dimension beliefs the annual derive pass
; mints; a subject the cascade has not derived yet (children, fresh spawns)
; holds its (dim ...) inputs absent, so the classifier skips and the
; classification waits for the first derive - same admission rule as the old
; annual pass. Booleans compose as products of (>= / <= / has) 0-or-1 terms;
; OR = (clamp (+ ...) 0 1).
; ----------------------------------------------------------------------------

; drunkard: a standing craving for drink IS the dependency.
(classify prototype
  (kind [k prototype drunkard])
  (when (present craving)))

; nouveau_riche: high wealth (>= 0.60) carried by low breeding (<= 0.35) -
; new money, not old blood. Thresholds mirror situations.hs prototype-tuning.
(classify prototype
  (kind [k prototype nouveau_riche])
  (when (* (>= (dim wealth) 0.60)
           (<= (dim breeding) 0.35))))

; self_made_man: a low-born man risen into the middle class or above on a
; sound character - rising trajectory + arrived class + low breeding +
; reputable standing.
(classify prototype
  (kind [k prototype self_made_man])
  (when (* (has social_trajectory [k social_trajectory rising])
           (clamp (+ (has class_situation [k class_situation middle])
                     (has class_situation [k class_situation upper])) 0 1)
           (<= (dim breeding) 0.40)
           (clamp (+ (has respectability_situation [k respectability_situation exemplary])
                     (has respectability_situation [k respectability_situation respectable])) 0 1))))

; deserving_poor / undeserving_poor: the shared economic test (poor or
; destitute), split on respectability.
(classify prototype
  (kind [k prototype deserving_poor])
  (when (* (clamp (+ (has economic_situation [k economic_situation poor])
                     (has economic_situation [k economic_situation destitute])) 0 1)
           (clamp (+ (has respectability_situation [k respectability_situation exemplary])
                     (has respectability_situation [k respectability_situation respectable])) 0 1))))

(classify prototype
  (kind [k prototype undeserving_poor])
  (when (* (clamp (+ (has economic_situation [k economic_situation poor])
                     (has economic_situation [k economic_situation destitute])) 0 1)
           (clamp (+ (has respectability_situation [k respectability_situation disreputable])
                     (has respectability_situation [k respectability_situation scandalous])) 0 1))))
