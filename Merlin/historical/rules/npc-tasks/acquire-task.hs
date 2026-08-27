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

(include "../../macros/money_macros.hs")
(include "../../macros/acquisition_macros.hs")
(include "../../definitions/roles.hs")

(npc-task {@self acquire ?kind ?disc}:?acq-rel
  (tar ?)
  (aux ?)
  (and
    ; RETRIEVE - an instance already in my home, unheld -> fetch it.
    (try
      (role ?mine ?kind {@self own ?mine} (spatial ?mine building (home-of @self)))
      (when (and (not (spatial ?mine co-located @self))
                 (unknown (spatial ?mine held_by))))
      (utility always-pick)
      (effects (maintain-proposal {@self get ?mine})))
    ; BUY - overt only; (feasible) drops it when broke, (cost) charges the felt price.
    (try
      (when (not (is-a ?disc [k covert])))
      (effects (maintain-proposal {@self buy ?kind}
                 (feasible (>= (coin-balance @self) (price ?kind)))
                 (cost     (money-cost-util (coin-balance @self) (price ?kind))))))
    ; HIRE - covert paid channel; agent fee folded into the price gate.
    (try
      (role ?agent (any_human ?agent) (personally-knows @self ?agent))
      (when (is-a ?disc [k covert]))
      (effects (maintain-proposal {@self hire-procure ?agent ?kind}
                 (feasible (>= (coin-balance @self) (+ (price ?kind) (procure_fee))))
                 (cost     (money-cost-util (coin-balance @self) (+ (price ?kind) (procure_fee)))))))
    ; STEAL - floored last resort, only while crime is enabled.
    (try
      (when (> (crime-scale) 0))
      (utility fallback)
      (effects (maintain-proposal {@self steal ?kind})))
    ; DONE - an instance of the kind is in hand, however it arrived.
    (try
      (when (not (empty (spatial @self hold ?kind))))
      (effects (set-outcome ?acq-rel succ)))))
