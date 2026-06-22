; ----------------------------------------------------------------------------
; means_cascade - a kill-method's MEANS acquired by PLAN-AS-YOU-GO (4.13 C/D/G).
;
; The generalization of the Phase C poison cascade to ALL weapon-gated kill
; methods: a killer whose chosen method needs a tool in hand (poison->toxin,
; shoot->firearm, stab->blade, garrotte->cord_or_wire ...) DERIVES and EXECUTES
; the errand to obtain it, instead of the tool being conjured at strike time.
;
; CASCADE events (no schedule; fired only by run_cascade, forward-chained for one
; perp over a per-deliberation hsim-wm scratch overlay). The magic atom `means`
; is the perp's method's required-control kind (resolve_cascade_kind ->
; g_cascade.means_kind, set by the trigger run_means_acquisition_cascades). The
; chain:
;   1. has no `means` (real possession, (controls ?actor means)) -> mint the
;      scratch subgoal {@self acquire means};
;   2. resolved + still unarmed -> the DURATIVE obtain act, scheduling its
;      completion `means_acquired` a real travel-time later (travel-minutes);
;   3. (completion, serial completion pass) acquire a REAL item of that kind into
;      the killer's hand (acquire-control -> acquire_weapon sets controlled_by).
; Once armed the trigger skips them (real-possession termination); the existing
; kill path consumes the held tool via its (control_any ...) requirement.
;
; Possession is the REAL model (States.mon axis (b) controlled_by / hold), not an
; invented belief. LOCAL-WRITE INVARIANT: deliberation writes only the actor's
; own hsim-wm; the world-write (acquire-control) fires in the completion pass.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

; Step 1 - the killer lacks the means and resolves to acquire it.
; IMPLICIT ACTOR (4.13 fork-B): a cascade event deliberated for one NPC declares
; NO actor role - the actor IS the deliberating NPC, referenced as @self (run_cascade
; binds it as E.self_actor).
(hsim-event means_plan_acquire
  (intra-day)
  (nl   "@self resolves to acquire the means for the deed")
  (when (and (has-means @self)
             (not (controls @self means))
             (not (believes {@self acquire means}))))
  ; NB: NO (log) here - this fires in the PARALLEL deliberation pass, and (log)
  ; appends to the shared narrative; only per-mind writes (the hsim-wm overlay)
  ; are allowed during deliberation. The acquisition is narrated by the serial
  ; means_acquired completion event instead.
  (effects
    (wm-begin-belief @self acquire means)))

; Step 2 - resolved + still unarmed -> the DURATIVE obtain act. (act ...) marks
; act-quiescence and schedules `means_acquired` a real round-trip travel-time
; later; the result lands at COMPLETION, not now.
(hsim-event means_plan_obtain
  (intra-day)
  (nl   "@self sets out to obtain the means")
  (when (and (has-means @self)
             (believes {@self acquire means})
             (not (controls @self means))))
  ; NO (log) - parallel deliberation pass (shared-write-free); the obtain act is
  ; narrated by means_acquired (serial completion).
  (effects
    (act means_acquired (travel-minutes @self means))))

; The COMPLETION-EVENT of the obtain act: fired by process_due_completions a
; travel-time later (serial completion pass; (completion-only) keeps it off the DES +
; per-NPC passes). acquire-control performs the REAL acquisition (acquire_weapon
; -> controlled_by), so the killer now physically holds the means. Implicit actor:
; process_due_completions binds the act's owner as @self.
(hsim-event means_acquired
  (schedule (completion-only))
  (nl   "@self returns having obtained the means")
  (effects
    (acquire-control @self means)
    (log _means_acquired @self)))

; NB: the kill STRIKE terminal (means_strike) was moved to
; historical/_unported_events/means_strike.hs when the place-lane crime passes were
; retired - re-port it as a co-presence cascade terminal alongside the kill behaviour.
