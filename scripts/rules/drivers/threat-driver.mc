; ----------------------------------------------------------------------------
; The victim holds the same conditional, told him, and answers it (answer-threat-pay,
; comply-with-threat-wed): the demand inside its condition is what he can do to avoid the
; outcome. Its worth is authored here today; projecting the outcome's cost is a later step.
; ----------------------------------------------------------------------------

(include "../../macros/acquisition-macros.mc")

(driver answer-threat-pay
  (role ?coercer {?coercer isa [k human], condition [k alive]}
                 {?coercer threaten @self (consequence (none {@self pay ?coercer /ever}) ?outcome ?deadline)}:?threat
                 -{@self pay ?coercer ? /succ /caused_by ?threat}
    (declare-utility want)
    (effects (maintain-proposal {@self pay ?coercer (blackmail_coins)}
               [/feasible (>= (carrying-cash-pile-count @self) (blackmail_coins))]))))
