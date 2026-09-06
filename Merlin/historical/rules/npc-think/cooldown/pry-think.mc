(include "../../../definitions/roles.mc")

; A witness anywhere in the BUILDING (a servant on the stairs, a co-resident in the
; next room) who sees an opposite-gender visitor with a married host, the host's
; spouse absent from the house, accrues suspicion of the host - in the WITNESS's OWN
; mind only (single POV). No write into any other mind. Building-scoped (not room)
; so a tryst behind a closed door is still witnessed by the household around it.
(npc-think pry
  (cooldown 1 m)
  (rng-stream incidents)
  (role @self {@self age-band [k young-adult|middle-aged|mature|elderly]})
  (role ?host {?host isa [k human], condition [k alive]} (spatial ?host co-located-building @self)
              {?host spouse ?host_spouse, gender ?host_gender})
  (role ?visitor {?visitor isa [k human], condition [k alive]} (spatial ?visitor co-located-building @self))
  (when (and (!= ?visitor ?host)
             (!= ?visitor @self)
             (!= ?visitor ?host_spouse)
             -{?visitor gender ?host_gender}
             (not (spatial ?host_spouse co-located-building @self))))
  (effects
    (nudge-stance ?host trust (- 0 (* 0.08 (+ 1 (hostility-toward ?host)))))))
