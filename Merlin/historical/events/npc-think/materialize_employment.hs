; ----------------------------------------------------------------------------
; materialize_employment - mint the employment BELIEFS for a worker the C++
; candidate-scan effects (bootstrap / staff_household / jockey / landlord) only
; ENROLLED on the register.
;
; The capstone of the hire() retirement (see macros/founding.hs): the objective
; substrate (the register enrolment) stays in the C++ effects - their candidate
; scans are engine queries - but the SUBJECTIVE beliefs move here, to .hs. A C++
; effect rosters @self via the thin enrol verb (no beliefs); this per-worker event
; then reconstructs the employment beliefs from the roster row, in @self's OWN mind
; (no telepathy - @self IS the worker).
;
;   when : @self holds no `employer` belief yet AND is rostered on some (non-club)
;          org's register (find-my-enrollment binds that org's ?articles).
;   then : read the matched job + level off @self's roster row and mint the
;          employment beliefs (hire-beliefs).
;
; Self-terminating: once the beliefs exist the `employer` gate is false, so a
; worker materializes exactly once. Two agendas share the body: STARTUP covers the
; cold-start bootstrap workers; the EMERGENT (monthly per-NPC) form covers workers
; the world lane enrols later (servants, jockeys, the landlord's estate seat).
;
; NOTE: while the C++ hire() still mints the employment beliefs itself (the steps
; before the critical flip), this event is a pure NO-OP - the `employer` gate is
; already true for every enrolled worker by the time it runs. It becomes load-
; bearing only once hire() is thinned to register-only.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

; --- emergent: workers the world lane enrols during the sim (monthly per-NPC) ---
(hsim-npc-behaviour materialize_employment
  (long-term-think)
  (rng-stream employment)

  (role @self (old_human @self))

  (when (not (believes {@self employer ?})))

  (effects
    (find-my-enrollment (bind ?art))
    (if ?art
      (do
        (read-doc-record [k articles_of_incorporation] ?art (register ?reg))
        (read-doc-record [k employee_register] ?reg
            (find worker @self) (job ?job) (level ?lvl))
        (hire-beliefs ?art ?job ?lvl)
        ))))

; --- startup: the cold-start bootstrap workers (one round-based per-NPC pass) ---
(hsim-npc-behaviour materialize_employment_startup
  (startup)
  (rng-stream employment)

  (role @self (any_human @self))

  (when (not (believes {@self employer ?})))

  (effects
    (find-my-enrollment (bind ?art))
    (if ?art
      (do
        (read-doc-record [k articles_of_incorporation] ?art (register ?reg))
        (read-doc-record [k employee_register] ?reg
            (find worker @self) (job ?job) (level ?lvl))
        (hire-beliefs ?art ?job ?lvl)
        ))))
