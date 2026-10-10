; ----------------------------------------------------------------------------
; acquire ?kind ?disc - the OBTAIN hub: come to hold an instance of ?kind. A driver
; PROPOSES it (means_think arms a shooter with a firearm); this task picks the METHOD
; and proposes the sub-task. ?disc (aux) is the discretion: [k covert] routes away from
; the traceable open purchase toward hiring or stealing, anything else is overt.
;
; Method order (relative, within the task - the task inherits its band from the driver):
;   retrieve : an instance I already keep at home, unheld -> just get it (always-pick).
;   buy      : overt only; dropped by (feasible) if I cannot pay, felt-costed if I can.
;   hire     : covert paid channel - a known agent procures it (someone else's trail).
;   steal    : the floored last resort (fallback), only while crime is enabled.
; Concludes the moment an instance of ?kind is in hand, however it arrived.
; ----------------------------------------------------------------------------

(include "../../macros/money-macros.mc")
(include "../../macros/acquisition-macros.mc")

(task {@self acquire ?kind ?disc}:?acquire
  (tar ?)
  (aux ?)
  (and
    ; RETRIEVE - an instance already in my home, unheld -> fetch it.
    (try
      (role ?mine (is-a ?mine ?kind) {@self own ?mine} (spatial ?mine building (any {@self home ?}).target)
        (when (and (not (spatial @self can-reach ?mine))
                   (unknown (spatial ?mine held-by))))
        (declare-utility always-pick)
        (effects (maintain-proposal {@self get ?mine}))))
    ; BUY - overt only; (feasible) drops it when broke, (cost) charges the felt price.
    (try
      (when (not (is-a ?disc [k covert])))
      (effects
        (any {@self carrying-cash.count ?coins=0})
        (maintain-proposal {@self buy ?kind}
          [/feasible (>= ?coins (price ?kind))]
          [/cost (money-cost-util ?coins (price ?kind))])))
    ; HIRE - covert paid channel; agent fee folded into the price gate.
    (try
      (role ?agent {?agent isa [k human], condition [k alive]} {@self (closeness-labels acquaintance) ?agent /ever}
        (when (is-a ?disc [k covert]))
        (effects
          (any {@self carrying-cash.count ?coins=0})
          (maintain-proposal {@self hire-procure ?agent ?kind}
            [/feasible (>= ?coins (+ (price ?kind) (procure_fee)))]
            [/cost (money-cost-util ?coins (+ (price ?kind) (procure_fee)))]))))
    ; STEAL - floored last resort, only while crime is enabled.
    (try
      (when (> (crime-scale) 0.0))
      (declare-utility fallback)
      (effects (maintain-proposal {@self steal ?kind})))
    ; DONE - an instance of the kind is in hand, however it arrived.
    (try
      (when (not (empty (spatial @self hold ?kind))))
      (effects (set-outcome ?acquire /succ)))))
