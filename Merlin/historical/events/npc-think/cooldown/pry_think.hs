(include "../../../definitions/roles.hs")

; A witness anywhere in the BUILDING (a servant on the stairs, a co-resident in the
; next room) who sees an opposite-gender visitor with a married host, the host's
; spouse absent from the house, accrues suspicion of the host - in the WITNESS's OWN
; mind only (single POV). No write into any other mind. Building-scoped (not room)
; so a tryst behind a closed door is still witnessed by the household around it.
(npc-think pry
  (cooldown 1 m)
  (rng-stream incidents)
  (role @self (adult @self))
  (role ?host (any_human ?host) (spatial ?host co-located @self /building)
              (believes {?host spouse ?host_spouse, gender ?host_gender}))
  (role ?visitor (any_human ?visitor) (spatial ?visitor co-located @self /building))
  (when (and (not (= ?visitor ?host))
             (not (= ?visitor @self))
             (not (= ?visitor ?host_spouse))
             (none {?visitor gender ?host_gender})
             (not (spatial ?host_spouse co-located @self /building))))
  (effects
    (bump-suspicion @self ?host (* 0.08 (+ 1 (hostility-toward ?host))))))
