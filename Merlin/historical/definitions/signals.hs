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

; visible-sobriety is RETIRED - it was a subject-side theory-of-mind SIMULATION of
; the town's reading (a halo prior), used ONLY by the old catalog repute. repute is
; per-observer now (events/classifiers/repute.hs): concealment EMERGES because private
; drinking generates no witnessed episode, so no observer bands the drinker's sobriety
; down - no simulated halo needed.

; reputed-chastity01 is RETIRED - reputed_chastity (the omniscient public band) is
; killed. repute's self-classification now reads @self's own TRUE chastity float
; (dim chastity) directly (0..1, @self-only, self-known); the per-observer OTHER
; chastity judgement lives in the consumers ((count-beliefs-about ?other lover)).

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

; generosity - the compassion prior, lifted 0.20 by any recorded act of charity
; (an ended {@self give <alms>} act-record still counts - a lifetime tally).
(classify generosity (value)
  (from (clamp (+ (attr compassion) (* (>= (count-ever give) 1) 0.20)) 0 1)))

; criminality is a value-dim DEF now - historical/macros/dimensions.hs (any-tense
; crime tally via (count-ever), read by life_aim). The (classify) form is retired.

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

; rootedness is a value-dim DEF now - historical/macros/dimensions.hs (present/count
; fold over local lineage / spouse / children / employer / property / clubs, read by
; life_aim). The (classify) form is retired.

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

; economic_situation is EVENTIFIED now - events/classifiers/economic_situation.hs
; bands the wealth dimension via (mint-band) in a (sim-window-think). The
; (classify ...) declaration here is retired (one writer only).

; class_situation + social_trajectory are EVENTIFIED now -
; events/classifiers/{class_situation,social_trajectory}.hs band the
; breeding/prestige/wealth fusion via (mint-band). The (classify ...) forms are
; retired (one writer only).

; respectability_situation is EVENTIFIED now -
; events/classifiers/respectability_situation.hs fuses the seven conduct dims
; (value-classifiers via (classifier-value ...) + the C++ chastity/decorum floats)
; and bands via (mint-band). The (classify ...) form is retired.

; repute is PER-OBSERVER now - events/classifiers/repute.hs derives {X repute <band>}
; from (repute-fold X) (the conduct bands + devoutness + decorum + per-observer chastity)
; for BOTH @self (mint-band) and each tracked other (mint-band-about, in @self's own pool),
; replacing this omniscient self-classifier + the believe_about repute mirror. The
; (classify ...) form is retired.

; inhibition is a value-dim DEF now - historical/macros/dimensions.hs (the moral /
; conscientious brake fold). Its consumers read the (inhibition) macro: .hs gates
; (ambition / covet), the eventified coward identity, and the displace-victim propensity
; (passed in as (- 1 (inhibition))). The (classify) form is retired.

; life_aim is EVENTIFIED now - events/classifiers/life_aim.hs runs the seven-aim
; argmax via (mint-argmax) (core-episode preserved). The (classify ...) form is
; retired.
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

; The five prototypes (drunkard / nouveau_riche / self_made_man / deserving_poor
; / undeserving_poor) are EVENTIFIED now - events/classifiers/prototypes.hs
; toggles each via (mint-band {@self prototype} <bool> [k prototype <p>] 0.5). The
; (classify ...) forms are retired.
