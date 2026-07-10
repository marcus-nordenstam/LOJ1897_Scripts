; ----------------------------------------------------------------------------
; Emigration. Leaving the parish happens to a SPECIFIC person, not to the world,
; so it is a per-NPC decision: it runs in the (long-term-think) window-start pass
; with @self bound to each living NPC. The young_adult template gates @self to a
; fertile-age adult, and a per-month (chance) - scaled by the parish's crowding
; (population-pressure) and by @self's own openness - rolls the departure. No role
; casting (the old world-act enumerated a ?who role; this binds @self O(1)).
;
; MARK-then-SWEEP, mirroring death: (mark-emigrating @self) only sets the
; emigrating marker; the zero-role (sweep-emigrants) world-act collects every
; marked entity and destroys it later. A per-NPC think must NEVER destroy an
; entity itself (it would corrupt the in-flight agent walk). The spouse belief is
; ended here so the survivor is not left referencing someone who has gone.
;
; Crowding feedback: at carrying capacity (pressure 1.0) the monthly base is
; 0.00125 ~= the old 1.5%/yr baseline; a crowded parish raises the outflow, a
; sparse one (immigration territory) sheds almost no one. This replaces the old
; homeostat_emigration "emigrate the oldest N by fiat" valve, which reached in and
; removed specific NPCs regardless of their own disposition.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-npc-behaviour emigration
  (long-term-think)
  (rng-stream migrations)

  (role @self (young_adult @self))

  (when (chance (* 0.00125 (+ 0.5 (attr @self openness)) (population-pressure))))

  (effects
    (end-belief      @self spouse)
    (mark-emigrating @self)
    ))
