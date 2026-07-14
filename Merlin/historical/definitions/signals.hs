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
