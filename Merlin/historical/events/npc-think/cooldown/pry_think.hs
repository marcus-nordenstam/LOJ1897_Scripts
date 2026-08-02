(include "../../../definitions/roles.hs")

; A co-present adult who sees an opposite-gender visitor alone with a married
; host (the host's spouse not in the room) accrues suspicion of the host - in
; the WITNESS's OWN mind only (single POV). No write into any other mind.
(npc-think pry
  (cooldown 1 m)
  (rng-stream incidents)
  (role @self (adult @self))
  (role ?host (any_human ?host) (co-present @self)
              (believes {?host spouse ?host_spouse, gender ?host_gender}))
  (role ?visitor (any_human ?visitor) (co-present @self))
  (when (and (not (= ?visitor ?host))
             (not (= ?visitor @self))
             (not (= ?visitor ?host_spouse))
             (not (believes {?visitor gender ?host_gender}))
             (not (co-present @self ?host_spouse))))
  (effects
    (bump-suspicion @self ?host (* 0.08 (+ 1 (hostility-toward ?host))))))
