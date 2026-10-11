; ----------------------------------------------------------------------------
; Threats, held. {@self threaten ?victim (consequence <condition> <outcome> <deadline>)} is the
; coercer's commitment: at the deadline, if its condition still holds in his mind (he has not
; seen it met), its outcome becomes his intent and the intent's pursuit carries it out
; (carry-out-threat). Seen met before then, it lapses (lapse-threat). Carried out, it is spent
; (reflexes/spent-threat.mc).
; ----------------------------------------------------------------------------

(think lapse-threat
  (role ?victim {?victim isa [k human]}
                {@self threaten ?victim (consequence ?condition ?outcome ?deadline)}:?threat
    (when (not (eval ?condition)))
    (effects (end-belief ?threat))))
