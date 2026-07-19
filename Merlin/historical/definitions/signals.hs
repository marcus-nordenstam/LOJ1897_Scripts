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
; pretender fools it by design (practice, not faith). A monthly churchgoer
; saturates; a quarterly attender reads ~0.5; a 2-year lapse fades out.
(def observance (evidence worship (half-life 6) (saturate 6)))

; devoutness - the observance reading banded to the piety_band kinds. A monthly
; churchgoer's mass saturates devout; a quarterly attender reads observant; a
; 2-year lapse decays through observant to secular as the memories age. The
; floor band (secular, min -1) means every NPC carries a reading. Read about
; ANOTHER person it uses only the worship episodes the observer holds.
(classify devoutness
  (about others)
  (from observance)
  (bands ([k piety_band devout]    0.55)
         ([k piety_band observant] 0.15)
         ([k piety_band secular]   -1)))
