; ----------------------------------------------------------------------------
; Emigration - the DECISION to leave the parish. Leaving happens to a SPECIFIC
; person, not to the world, so it is a per-NPC decision, with @self bound to
; each living NPC. The
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

(include "../../../definitions/roles.hs")

; TERMINAL step (act_body_purification): the depart act is PROPOSED, not promoted by
; the bare {@self depart} goal - goals never propose themselves, so the latched goal above
; only DRIVES this terminal. depart is a self-act with no venue, so the standing goal IS the
; whole readiness: it re-proposes {@self depart} each env-cycle until depart_act runs.
; depart_act ends its own act-belief and destroys @self, so the propose stops when the
; emigrant is gone. Utility above routine work so a resolved departure actually executes.
(npc-think depart_now
  (goal {@self depart})
  (utility 82)
  (effects (maintain-proposal {@self depart})))

; The teardown twin: the packing day concluded - quit his posts, release his
; home, and leave. All reads are his OWN beliefs (think-side); the walks skip
; whatever a jobless / homeless emigrant lacks. destroy-entity ends the mind,
; which closes this twin's own gate.
(npc-think departed
  (role @self {@self depart /succ})
  (effects
    (for-each ?jb (every {@self job ?})
        ?jb.target: ?job
        (for-each ?ob (every {?job org ?})
            ?ob.target: ?org
            (for-each ?ab (every {?org record ?})
                ?ab.target: ?art
                (read-doc-record [k articles_of_incorporation] ?art (register ?reg))
                (remove-doc-record [k employee_register] ?reg (find worker @self))))
        (end-belief ?jb))
    (for-each ?hb (every {@self home ?})
        ?hb.target: ?home
        (if (any {@self own ?home} (out int))
          (then
            (create-entity [k for_sale_listing] (qual location ?home) (bind ?listing))
            (write-doc-record [k for_sale_listing] ?listing (building ?home))
            (end-belief {@self own ?home})
            (end-belief {@self home ?home}))
          (else
            (if (any {?home tenant @self} (out int)) (then (end-belief {?home tenant @self})))
            (end-belief {@self home ?home}))))
    (end-belief {@self spouse})
    (destroy-entity @self)))
