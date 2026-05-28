; ----------------------------------------------------------------------------
; op_return_ranges.hsc - declared return ranges for hse-engine evaluator
; functions.
;
; Loaded by Merlin at ontology-load time. Read by hse_engine's
; (chance ...) static-bound analyser (compute_max_bound) when an op
; appears inside a chance expression - the analyser uses [lo, hi] to
; bound the chance expression's range so it can pre-roll the cheap
; majority of failing candidates.
;
; The C++ evaluator implementations live in hse_engine.cc; this file
; ONLY captures their externally-visible numeric return contracts. No
; hardcoded range values in the C++ - every op that compute_max_bound
; needs to bound has a row here.
;
; Format:
;   (op-return-range <op-name> <lo> <hi>)
;
; Predicates returning v_bool (which folds to 0/1 via truthy()) all
; have range 0..1; signed scalars use their natural numeric range.
;
; Ops NOT listed here have no declared return range - they're either
; unbounded (count-beliefs, belief-age, ...) or non-numeric (kind /
; entity / atom returners). compute_max_bound returns std::nullopt for
; chance expressions that include them.
; ----------------------------------------------------------------------------

; ---- Perpetration / interaction predicates ---------------------------------
(op-return-range victim-state            0  1)
(op-return-range in-season               0  1)
(op-return-range has-authority-over      0  1)
(op-return-range personally-knows        0  1)
(op-return-range holds-secret-about      0  1)
(op-return-range can-write               0  1)
(op-return-range control                 0  1)
(op-return-range control-any             0  1)
(op-return-range access                  0  1)
(op-return-range access-any              0  1)

; months-since-death: practical upper bound = sim duration (~200 years x
; 12 months); padded.
(op-return-range months-since-death      0  3000)

; ---- Structural-friction helpers (PR-A-2) ----------------------------------
; Triangulation predicates return v_bool (0/1). prestige-gap and
; life-aim-aligns are signed scalars; value-rift is a 0..1 mismatch
; fraction.
(op-return-range triangulation-parental  0  1)
(op-return-range triangulation-romantic  0  1)
(op-return-range class-interloper        0  1)
(op-return-range succession-rival        0  1)
(op-return-range replacement-threat      0  1)
(op-return-range frequents-overlap       0  1)
(op-return-range value-rift              0  1)
; prestige-gap reads prestige (now 0..1 post-normalisation) on both
; sides and returns the signed difference, so its range is [-1, 1].
(op-return-range prestige-gap           -1  1)

; ---- PR-A-3: life_aim alignment lookup -------------------------------------
; Reads life_aim_affinity.hsc rows. The rows author signed weights in
; roughly [-1, 1]; this is the bound the static analyser uses.
(op-return-range life-aim-aligns        -1  1)

; ---- PR-A-7: per-pair cooldown read for bonded / public incidents ---------
(op-return-range has-recent-incident-marker  0  1)

; ---- Intrinsic chance semantics --------------------------------------------
; Mathematical contract: (chance p) returns a probability in [0, 1]
; (truthy fold of the Bernoulli outcome). Captured here so the static
; analyser also queries this from data, not from a C++ literal.
(op-return-range chance                  0  1)

; ---- (year) op - simulation calendar year ----------------------------------
; The bound is wider than the canonical hsim 1700..1897 sweep so any
; configured start/end stays within the over-approximation. (year) reads
; the simulator's current calendar year inside event-eval; the static
; analyser uses these outer bounds when (year) appears inside (chance).
(op-return-range year                 1700  1900)
