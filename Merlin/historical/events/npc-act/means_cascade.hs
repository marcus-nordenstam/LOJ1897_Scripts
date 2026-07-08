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
(hsim-npc-behaviour means_plan_acquire
  (short-term-think)
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
(hsim-npc-behaviour means_plan_obtain
  (short-term-think)
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
(hsim-npc-behaviour means_acquired
  (on-completion)
  (effects
    ; DEMAND RE-VALIDATION. The obtain act is a demand-derived sub-act: it exists
    ; only to serve a kill the actor still intends. A durative sub-act must stay
    ; demand-gated for its WHOLE duration, not just at launch - so re-check the
    ; demand at completion. If the kill goal lapsed while the actor was travelling
    ; to get the tool (the victim died and the alive-gate pruned the goal, or the
    ; grudge faded), do NOT acquire a weapon for an abandoned kill.
    (if (has-goal kill)
        (acquire-control @self means))
    ))

; NB: the kill STRIKE terminal (means_strike) was moved to
; historical/_unported_events/means_strike.hs when the place-lane crime passes were
; retired - re-port it as a co-presence cascade terminal alongside the kill behaviour.
