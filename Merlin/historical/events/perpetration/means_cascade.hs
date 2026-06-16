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
(hsim-event means_plan_acquire
  (cascade)
  (nl   "?actor resolves to acquire the means for the deed")
  (kind _means_plan)
  (roles (role ?actor (template any_human)))
  (when (and (not (controls ?actor means))
             (not (believes ?actor {@self acquire means}))))
  (effects
    (wm-begin-belief ?actor acquire means)
    (log _means_plan ?actor)))

; Step 2 - resolved + still unarmed -> the DURATIVE obtain act. (act ...) marks
; act-quiescence and schedules `means_acquired` a real round-trip travel-time
; later; the result lands at COMPLETION, not now.
(hsim-event means_plan_obtain
  (cascade)
  (nl   "?actor sets out to obtain the means")
  (kind _means_plan)
  (roles (role ?actor (template any_human)))
  (when (and (believes ?actor {@self acquire means})
             (not (controls ?actor means))))
  (effects
    (log _means_plan ?actor)
    (act means_acquired (travel-minutes ?actor means))))

; The COMPLETION-EVENT of the obtain act: fired by process_due_completions a
; travel-time later (serial completion pass; (chain-only) keeps it off the DES +
; per-NPC passes). acquire-control performs the REAL acquisition (acquire_weapon
; -> controlled_by), so the killer now physically holds the means.
(hsim-event means_acquired
  (schedule (chain-only))
  (nl   "?actor returns having obtained the means")
  (kind _means_acquired)
  (roles (role ?actor (template any_human)))
  (effects
    (acquire-control ?actor means)
    (log _means_acquired ?actor)))
