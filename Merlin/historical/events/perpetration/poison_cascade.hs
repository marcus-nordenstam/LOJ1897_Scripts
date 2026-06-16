; ----------------------------------------------------------------------------
; poison_cascade - the poison-kill goal ported to PLAN-AS-YOU-GO (4.13 C/D).
;
; CASCADE events: no (schedule); never DES-seeded or per-NPC-fired. The cascade
; driver (run_cascade) forward-chains them for ONE poison-method killer at a time
; over a per-deliberation hsim-wm SCRATCH overlay, reading the KNOWLEDGE VIEW
; (committed ltm + scratch subgoals + REAL possession attrs). The chain:
;   1. has no poison (real possession, (controls ?actor toxin)) -> mint the
;      scratch subgoal {@self acquire toxin};
;   2. resolved to acquire + still has none -> emit the DURATIVE obtain act,
;      scheduling its completion `poison_acquired` 480 minutes later;
;   3. (completion, a duration later, in the serial completion pass) acquire a
;      REAL toxin into the killer's hand (acquire-control -> acquire_weapon sets
;      controlled_by). Now (controls ?actor toxin) is true.
; The killer is BUSY between obtain and completion; once armed (controls toxin)
; the trigger skips them - the goal is satisfied via real possession, no monthly
; re-planning, and the kill path uses the held poison.
;
; Possession is the REAL model (States.mon axis (b) physical control:
; controlled_by / hold), NOT an invented belief. Subgoal/act labels conform to
; existing Tasks.mon (acquire) + the toxin kind poison `:requires (control_any
; toxin)`.
;
; LOCAL-WRITE INVARIANT (4.13): the cascade deliberation writes only the actor's
; own hsim-wm; the real world-write (acquire-control) fires in the COMPLETION
; pass (poison_acquired), serially - never in deliberation.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

; Step 1 - the killer has no poison and resolves to acquire some.
(hsim-event poison_plan_acquire
  (cascade)
  (nl   "?actor settles on poison and resolves to acquire some")
  (kind _poison_plan)
  (roles (role ?actor (template any_human)))
  (when (and (not (controls ?actor toxin))
             (not (believes ?actor {@self acquire toxin}))))
  (effects
    (wm-begin-belief ?actor acquire toxin)
    (log _poison_plan ?actor)))

; Step 2 - resolved + still unarmed -> the DURATIVE obtain act. (act ...) marks
; act-quiescence and schedules `poison_acquired` 480 minutes (~a day's errand)
; later; the result lands at COMPLETION, not now.
(hsim-event poison_plan_obtain
  (cascade)
  (nl   "?actor sets out to obtain the poison")
  (kind _poison_plan)
  (roles (role ?actor (template any_human)))
  (when (and (believes ?actor {@self acquire toxin})
             (not (controls ?actor toxin))))
  (effects
    (log _poison_plan ?actor)
    ; 4.13 Phase E: the obtain act's duration is the REAL round-trip travel time
    ; to the nearest acquirable toxin (distance / speed), not a flat constant -
    ; so the completion lands a believable travel-time later (clue coherence).
    (act poison_acquired (travel-minutes ?actor toxin))))

; The COMPLETION-EVENT of the obtain act: fired by process_due_completions a
; duration later (serial completion pass). (chain-only) keeps it off the DES +
; per-NPC passes; it fires only via the completion heap with the actor preset.
; acquire-control performs the REAL acquisition (acquire_weapon -> controlled_by),
; so the killer now physically holds the toxin.
(hsim-event poison_acquired
  (schedule (chain-only))
  (nl   "?actor returns having obtained the poison")
  (kind _poison_acquired)
  (roles (role ?actor (template any_human)))
  (effects
    (acquire-control ?actor toxin)
    (log _poison_acquired ?actor)))
