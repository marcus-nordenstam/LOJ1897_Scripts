; ----------------------------------------------------------------------------
; pursue-acquire - an intent to come to hold an instance of ?kind. Fetching one he keeps at
; home comes first. An acquisition a killing caused is COVERT - no purchase record to trace
; back to it - so an acquaintance procures it; any other is bought openly. While crime is
; enabled, stealing from a shop is the last resort. A shop is searched for while he knows
; none. Any means concluding ends the intent.
; ----------------------------------------------------------------------------

(include "../../../macros/money-macros.mc")
(include "../../../macros/acquisition-macros.mc")

(driver {@self intent {@self acquire ?kind}}:?intent
  (and
    (try
      (role ?mine (is-a ?mine ?kind) {@self own ?mine} (spatial ?mine building (any {@self home ?}).target)
        (when (unknown (spatial ?mine held-by)))
        (declare-utility always-pick)
        (effects (maintain-proposal {@self get ?mine}))))
    (try
      (no-role [k shop])
      (when -{@self find-building [k shop] ? /fail})
      (effects (maintain-proposal {@self find-building [k shop] (current-exterior @self)})))
    (try
      (role ?shop [k shop] (select (policy first-match))
        (when (not (has-cause ?intent {@self intent {@self kill ?}})))
        (effects
          (maintain-proposal {@self buy ?kind}
            [/feasible (>= (carrying-cash-count @self) (price ?kind))]
            [/cost (money-cost-util (carrying-cash-count @self) (price ?kind))]))))
    (try
      (role ?agent {?agent isa [k human], condition [k alive]} {@self (closeness-labels acquaintance) ?agent /ever}
        (when (has-cause ?intent {@self intent {@self kill ?}}))
        (effects
          (maintain-proposal {@self hire-procure ?agent ?kind}
            [/feasible (>= (carrying-cash-count @self) (+ (price ?kind) (procure_fee)))]
            [/cost (money-cost-util (carrying-cash-count @self) (+ (price ?kind) (procure_fee)))]))))
    (try
      (role ?shop [k shop] (select (policy first-match))
        (when (> (crime-scale) 0.0))
        (declare-utility fallback)
        (effects (maintain-proposal {@self steal ?kind}))))))
