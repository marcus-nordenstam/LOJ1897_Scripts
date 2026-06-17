; ----------------------------------------------------------------------------
; day_shape - the per-NPC daily routine as PLAN-AS-YOU-GO cascade rules (4.13.14
; fork-B). This DATA replaces the old hardcoded sleep/work/outing/go-home state
; machine in C++. deliberate_next_act runs the cascade; the first rule whose
; (when ...) holds emits an act ((go ...) / (stay ...)); the act's completion a
; duration later re-deliberates the NPC, so the day shape emerges step by step.
;
; IMPLICIT ACTOR: a (cascade) event declares NO actor role - the actor IS the
; deliberating NPC, referenced as ?self (run_cascade binds it). The rules read
; everything they need DECLARATIVELY through the day-shape ops: now-hour, has-job,
; self-at, workplace-of / home-of, in-work-hours / work-starts-soon, the (stay)
; durations (minutes-until-shift-end / minutes-until-alarm), and leisure-venue.
;
; PRIORITY = file order: run_cascade evaluates events in catalog order and STOPS
; at the first act emitted, so earlier rules out-rank later ones. Acquisition
; (perpetration/means_cascade.hs) loads first (alphabetically), so an unarmed
; killer's weapon-errand out-ranks the day shape; once armed they fall through to
; the routine below.
; ----------------------------------------------------------------------------

; 1. WORK - at the workplace during (or just before) the shift: stay until it ends.
;    One (stay) spans the whole shift (and any pre-start wait); the completion at
;    shift-end re-deliberates (-> go home / outing).
(hsim-event day_work
  (cascade)
  (when (and (self-at (workplace-of ?self))
             (or (in-work-hours ?self) (work-starts-soon ?self))))
  (effects (stay (minutes-until-shift-end ?self))))

; 2. GO TO WORK - the shift is on or imminent and the NPC is not yet there:
;    set out (a (go) travel act). DETERMINISTIC for now (no industriousness roll) -
;    the parallel deliberation pass is kept RNG-free in this first cut; absenteeism /
;    shirking returns later with a per-NPC RNG. Evening outings (which need the
;    leisure-venue picker, not yet parallel-safe) are likewise deferred.
(hsim-event day_go_to_work
  (cascade)
  (when (and (has-job ?self)
             (or (in-work-hours ?self) (work-starts-soon ?self))
             (not (self-at (workplace-of ?self)))))
  (effects (go ?self (workplace-of ?self))))

; 3. SLEEP - at home at night: sleep until the morning alarm (a worker rises an
;    hour before the shift; everyone else at the default wake hour).
(hsim-event day_sleep
  (cascade)
  (when (and (self-at (home-of ?self))
             (or (>= (now-hour) 22) (< (now-hour) 6))))
  (effects (stay (minutes-until-alarm ?self))))

; 6. GO HOME - anywhere else (after work, after an outing): head home. The lowest-
;    priority routine rule; if even this cannot fire (no home), deliberate_next_act
;    falls back to a 3h idle.
(hsim-event day_go_home
  (cascade)
  (when (not (self-at (home-of ?self))))
  (effects (go ?self (home-of ?self))))
