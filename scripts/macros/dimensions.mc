; ----------------------------------------------------------------------------
; dimensions.mc - value-dimension DEFS (define-macro). A value dim is a 0..1
; magnitude a fusion or utility reads on demand - never a minted belief. Each is
; an ordinary zero-arg macro inlined by every consumer (written (dimname)), so
; there is ONE encoding and no classifier catalog to evaluate it.
;
; The macro bodies are ordinary .mc read/fold expressions (attr / believes /
; (count (every ..)) / evidence + the + - * / min max clamp >= <=
; combinators). (believes {@self L ?}) is the boolean "holds an ongoing L"
; (0-or-1 in arithmetic); (count (every {@self L ?})) the ongoing tally;
; (count (every {@self L ? /ever})) the any-tense tally (ended act-records count); the
; per-attr default is 0 when absent (traits are always present on generated
; humans).
; ----------------------------------------------------------------------------

; --- per-observer repute fold (uniform for @self and a tracked other) ------------
; repute reads BANDED conduct beliefs {X <dim> <conduct-level>} + {X devoutness},
; the {X decorum} float, and per-observer chastity - all keyed on ?who, so ONE fold
; serves self-repute (?who = @self) and other-repute (?who = a tracked person). An
; absent band reads `fair` (unknown -> benefit of the doubt, 0.65), so an unknown
; other reads RESPECTABLE and only accumulated negative evidence drags them down;
; reputation sharpens only with evidence.














