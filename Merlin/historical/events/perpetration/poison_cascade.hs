; ----------------------------------------------------------------------------
; poison_cascade - the poison-kill goal ported to PLAN-AS-YOU-GO (4.13 Phase C).
;
; These are CASCADE events: they carry no (schedule) and are never DES-seeded or
; per-NPC-fired. The engine's cascade driver (run_cascade) forward-chains them
; for one actor at a time - a poison-method month-kill perpetrator - over a
; per-deliberation hsim-wm SCRATCH overlay. Each event's (when ...) reads the
; KNOWLEDGE VIEW (the actor's committed beliefs + this deliberation's scratch
; subgoals) and its `wm-`-prefixed effect mints the next subgoal into the
; overlay, which the next event's condition then sees. The chain self-extinguishes
; (each step's guard is "have I already minted this subgoal?"), so it reaches
; fixpoint after one sweep.
;
; This is the acquisition TRAJECTORY a killer derives instead of poison being
; conjured: need poison -> learn where to get it -> go obtain it. The subgoals
; are flat task-beliefs over EXISTING Tasks.mon labels (acquire / locate / get);
; no new ontology. The `(log ...)` writes the trajectory to the narrative so the
; cascade is observable. (Gating the actual poison kill on this acquisition is
; the load-bearing follow-up; this cut leaves the bespoke poison rate intact.)
;
; LOCAL-WRITE INVARIANT (4.13): every effect here writes ONLY the deliberating
; actor's own mind (hsim-wm scratch). No effect touches another mind.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

; Step 1 - the killer registers that poisoning needs poison they do not have:
; mint the scratch subgoal {@self acquire poison}.
(hsim-event poison_plan_acquire
  (cascade)
  (nl   "?actor settles on poison and resolves to acquire some")
  (kind _poison_plan)
  (roles (role ?actor (template any_human)))
  (when (not (believes ?actor {@self acquire poison})))
  (effects
    (wm-begin-belief ?actor acquire poison)
    (log _poison_plan ?actor)))

; Step 2 - having resolved to acquire it, the killer does not yet know WHERE:
; mint the scratch subgoal {@self locate poison}.
(hsim-event poison_plan_locate
  (cascade)
  (nl   "?actor considers where poison might be obtained")
  (kind _poison_plan)
  (roles (role ?actor (template any_human)))
  (when (and (believes ?actor {@self acquire poison})
             (not (believes ?actor {@self locate poison}))))
  (effects
    (wm-begin-belief ?actor locate poison)
    (log _poison_plan ?actor)))

; Step 3 - knowing where, the killer commits to the TERMINAL ACT: travel to
; obtain the poison. This is a DURATIVE act - (act ...) marks act-quiescence (the
; cascade stops here) and schedules its completion `poison_acquired` 480 minutes
; (~a day's errand) later. The act's RESULT lands at COMPLETION, not now - the
; whole point of the completion heap.
(hsim-event poison_plan_obtain
  (cascade)
  (nl   "?actor sets out to obtain the poison")
  (kind _poison_plan)
  (roles (role ?actor (template any_human)))
  (when (believes ?actor {@self locate poison}))
  (effects
    (log _poison_plan ?actor)
    (act poison_acquired 480)))

; The COMPLETION-EVENT of the obtain act: fired by process_due_completions a
; duration after the act was chosen (NOT a cascade event; NOT DES-seeded or
; per-NPC-fired - (chain-only) keeps it off both, it only fires via the
; completion heap with the actor preset). This is where the act's terminal
; effect lands: the killer now has the poison.
(hsim-event poison_acquired
  (schedule (chain-only))
  (nl   "?actor returns having obtained the poison")
  (kind _poison_acquired)
  (roles (role ?actor (template any_human)))
  (effects
    (log _poison_acquired ?actor)))
