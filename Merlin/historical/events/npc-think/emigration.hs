; ----------------------------------------------------------------------------
; Emigration - the DECISION to leave the parish. Leaving happens to a SPECIFIC
; person, not to the world, so it is a per-NPC decision: it runs in the
; (long-term-think) window-start pass with @self bound to each living NPC. The
; young_adult template gates @self to a fertile-age adult, and a per-month
; (chance) - scaled by the parish's crowding (population-pressure) and by @self's
; own openness - rolls the departure. @self is bound O(1); there is no role cast.
;
; This is a pure DECISION think (mirrors clubs.hs club_resignation): it only mints
; the standing act-goal {@self depart}. The teardown - quitting the job, releasing
; the home, and leaving the world - is @self's OWN act (npc-act/depart.hs), which
; acts entirely on @self and @self's own beliefs. No mark, no sweep: a departing
; person removes THEMSELVES.
;
; (begin-goal ...) not (excl-goal ...): the decision fires once (a monthly chance),
; so the goal must LATCH until the depart act consumes it. An excl-goal evaporates
; the moment a cycle stops re-stamping it, and this think will not re-fire.
;
; Crowding feedback: at carrying capacity (pressure 1.0) the monthly base is
; 0.00125 ~= a 1.5%/yr baseline; a crowded parish raises the outflow, a sparse one
; (immigration territory) sheds almost no one.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-think emigration
  (long-term-think)
  (rng-stream migrations)

  (role @self (young_adult @self))

  (when (chance (* 0.00125 (+ 0.5 (attr @self openness)) (population-pressure))))

  (effects
    (begin-goal {@self depart})))
