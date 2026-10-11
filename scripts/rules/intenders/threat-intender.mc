; ----------------------------------------------------------------------------
; Threats, held. {@self threaten ?victim (consequence <condition> <outcome> <deadline>)} is the
; coercer's commitment: at the deadline, if its condition still holds in his mind (he has not
; seen it met), its outcome becomes his intent and the intent's pursuit carries it out
; (carry-out-threat). Seen met before then, it lapses (lapse-threat). Carried out, it is spent
; (reflexes/spent-threat.mc).
;
; The victim holds the same conditional, told him, and answers it (answer-threat-pay,
; comply-with-threat-wed): the demand inside its condition is what he can do to avoid the
; outcome. Its worth is authored here today; projecting the outcome's cost is a later step.
; ----------------------------------------------------------------------------

(intender carry-out-threat
  (cooldown 1 d try-until-succ)
  (role ?victim {?victim isa [k human], condition [k alive]}
                {@self threaten ?victim (consequence ?condition ?outcome ?deadline)}:?threat
    (when (and (>= (time seconds) ?deadline)
               (eval ?condition)))
    (declare-utility want)
    (effects (maintain-intent {@self intent ?outcome} /caused_by ?threat))))

; A daughter told she will be disinherited unless she weds the man her father chose resolves
; to wed him, caused by the threat.
(intender comply-with-threat-wed
  (role ?father {?father isa [k human], condition [k alive]}
                {?father threaten @self (consequence (none {@self wed ?groom /ever}) ?outcome ?deadline)}:?threat
    (declare-utility obligation)
    (effects (maintain-intent {@self intent {@self wed ?groom}} /caused_by ?threat))))
