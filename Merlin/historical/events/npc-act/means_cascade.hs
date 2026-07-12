; ----------------------------------------------------------------------------
; means_cascade - a kill-method's MEANS acquired by PLAN-AS-YOU-GO (4.13 C/D/G).
;
; The generalization of the Phase C poison cascade to ALL weapon-gated kill
; methods: a killer whose chosen method needs a tool in hand (poison->toxin,
; shoot->firearm, stab->blade, garrotte->cord_or_wire ...) DERIVES and EXECUTES
; the errand to obtain it, instead of the tool being conjured at strike time.
;
; INTRA-DAY events (no schedule; forward-chained for one perp by run_intra_day).
; The magic atom `means` is the perp's method's required-control kind
; (intra_day_means_kind_for -> g_intra_day.means_kind). The chain:
;   1. has no `means` (real possession, (controls ?actor means)) -> mint the
;      standing goal {@self acquire means} (a real belief - the killer's own
;      memory of setting out to arm);
;   2. resolved + still unarmed -> the DURATIVE obtain act, scheduling its
;      completion `means_acquired` a real travel-time later (travel-minutes);
;   3. (completion, serial completion pass) acquire a REAL item of that kind into
;      the killer's hand (acquire-control -> acquire_weapon sets controlled_by),
;      then end the acquire goal.
; Once armed the trigger skips them (real-possession termination); the existing
; kill path consumes the held tool via its (control_any ...) requirement.
;
; Possession is the REAL model (States.mon axis (b) controlled_by / hold), not an
; invented belief. The world-write (acquire-control) fires in the completion pass.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

; Step 1 - the killer lacks the means and resolves to acquire it.
; IMPLICIT ACTOR (4.13 fork-B): a cascade event deliberated for one NPC declares
; NO actor role - the actor IS the deliberating NPC, referenced as @self (run_cascade
; binds it as E.self_actor).
(npc-think means_plan_acquire
  (short-term-think)
  (when (and (has-means @self)
             (not (controls @self means))
             (not (goal? {@self acquire means}))))
  ; NB: NO (log) here - this fires in the deliberation pass, and (log) appends to
  ; the shared narrative. The goal is a self-write (safe under serial dispatch);
  ; the acquisition is narrated by the serial means_acquired completion event.
  (effects
    (begin-goal {@self acquire means})))

; Step 2 - resolved + still unarmed -> the DURATIVE obtain act. (act ...) marks
; act-quiescence and schedules `means_acquired` a real round-trip travel-time
; later; the result lands at COMPLETION, not now.
(npc-think means_plan_obtain
  (short-term-think)
  (when (and (has-means @self)
             (goal? {@self acquire means})
             (not (controls @self means))))
  ; NO (log) - parallel deliberation pass (shared-write-free); the obtain act is
  ; narrated by means_acquired (serial completion).
  (effects
    (begin-act {@self acquire} (travel-minutes @self means) means_acquired)))

; The COMPLETION-EVENT of the obtain act: fired by process_due_completions a
; travel-time later (serial completion pass; (completion-only) keeps it off the DES +
; per-NPC passes). acquire-control performs the REAL acquisition (acquire_weapon
; -> controlled_by), so the killer now physically holds the means. Implicit actor:
; process_due_completions binds the act's owner as @self.
(npc-think means_acquired
  (on-completion)
  (effects
    ; DEMAND RE-VALIDATION. The obtain act is a demand-derived sub-act: it exists
    ; only to serve a kill the actor still intends. A durative sub-act must stay
    ; demand-gated for its WHOLE duration, not just at launch - so re-check the
    ; demand at completion. If the kill goal lapsed while the actor was travelling
    ; to get the tool (the victim died and the alive-gate pruned the goal, or the
    ; grudge faded), do NOT acquire a weapon for an abandoned kill.
    (if (goal? {@self kill})
        (acquire-control @self means))
    (end-goal {@self acquire means})
    ))

; NB: the kill STRIKE terminal (means_strike) was moved to
; historical/_unported_events/means_strike.hs when the place-lane crime passes were
; retired - re-port it as a co-presence cascade terminal alongside the kill behaviour.
