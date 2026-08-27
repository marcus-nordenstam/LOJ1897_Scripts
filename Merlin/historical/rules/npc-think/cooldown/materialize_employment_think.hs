; ----------------------------------------------------------------------------
; materialize_employment - mint the employment BELIEFS for a worker the C++
; candidate-scan effects (bootstrap / staff_household / jockey / landlord) only
; ENROLLED on the register.
;
; The capstone of the hire() retirement (see macros/founding.hs): the objective
; substrate (the register enrolment) stays in the C++ effects - their candidate
; scans are engine queries - but the SUBJECTIVE beliefs move here, to .hs. A C++
; effect rosters @self via the thin enrol verb (no beliefs); this per-worker rule
; then reconstructs the employment beliefs from the roster row, in @self's OWN mind
; (no telepathy - @self IS the worker).
;
;   when : @self holds no `job.salary` belief yet AND is rostered on some (non-club)
;          org's register (find-my-enrollment binds that org's ?articles).
;   then : read the matched job + level off @self's roster row and mint the
;          employment beliefs (hire-beliefs).
;
; Self-terminating: once the beliefs exist the `job.salary` gate is false, so a
; worker materializes exactly once. Two agendas share the body: STARTUP covers the
; cold-start bootstrap workers; the EMERGENT (monthly per-NPC) form covers workers
; the world lane enrols later (servants, jockeys, the landlord's estate seat).
;
; NOTE: while the C++ hire() still mints the employment beliefs itself (the steps
; before the critical flip), this rule is a pure NO-OP - the `job.salary` gate is
; already true for every enrolled worker by the time it runs. It becomes load-
; bearing only once hire() is thinned to register-only.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; --- emergent: workers the world lane enrols during the sim (monthly per-NPC) ---
(npc-think materialize_employment
  (cooldown 1 m)
  (rng-stream employment)

  ; Jobless gate as a CACHED self-gate filter - empties the instant the NPC gains
  ; a paid job, so the employed majority skips the enrollment scan at zero cost.
  (role @self (old_human @self)
              (not {@self job.salary ?}))

  ; Quarterly pulse so the bout CEASES and re-arms: a worker enrolled AFTER this
  ; rule's one prior firing (the roster write is objective, in the abs mind, and
  ; does not wake the worker) would otherwise never re-scan and stay a beliefless
  ; phantom employee. The pulse re-attempts the enrollment scan until it mints.
  (when (or (in-month 3) (in-month 6) (in-month 9) (in-month 12)))

  (effects
    ; Scan the public incorporation registry for the NON-CLUB firm whose wage book
    ; lists @self, and rebuild his employment beliefs from that row. First hit wins
    ; (a worker holds one post); (break) ends the scan. A regular worker doesn't hold
    ; {?org record}, so the register is reached by this objective scan, not a belief walk.
    (for-each ?art (documents [k articles_of_incorporation])
      (do
        (read-doc-record [k articles_of_incorporation] ?art (kind ?ok) (register ?reg))
        (if (and (not (is-a ?ok [k org club]))
                 (read-doc-record [k employee_register] ?reg
                     (find worker @self) (job ?job) (level ?lvl)))
          (then
            (hire-beliefs ?art ?job ?lvl)
            (break)))))))

; NOTE: there is NO (startup) twin of this rule. At the cold-start (startup) pass the
; only enrollments are org HEADS (found-org-seq mints their beliefs inline), so a startup
; materialize had nobody to reconstruct - it fired for every adult x every startup round,
; each doing an O(all-docs) find-my-enrollment scan that always came back empty (verified:
; 0 reconstructions). That fruitless scan WAS the ~43s startup cost; deleting it removed
; it outright. Register-only enrollees (servants / jockeys / the landlord's seat, all
; enrolled MONTHLY by the staffing rules) are reconstructed by the
; emergent rule above, in the month they are enrolled.
