; ----------------------------------------------------------------------------
; work-attendance - the daily WORK-ATTENDANCE drivers, reading the job @self holds (a duty).
; The shift itself is tasks/work-task.mc.
;
; The labour market (employment.mc / business.mc / apprenticeship.mc) mints the
; job beliefs but never moves anyone; THIS chain is what physically gets
; an employed NPC to their workplace during their shift and holds them there.
; Gated on the beliefs the labour market mints, all resolved live as composable
; belief reads: (any {@self job.org ?org}) (any {?org workplace ?wp}) for the
; destination, and (current-shift ?job) for the job's working hours that are on or about
; to be. A missing job / workplace / shift fails the gate (no job, or a day off -> no
; commute).
;
; Two intra-day rules competing by (declare-utility); the intra-day deliberation commits
; the max-utility eligible act:
;   - day-work     : already AT the workplace during/just-before the shift -> a
;                    single (stay) spanning the rest of the shift; its completion
;                    re-deliberates (-> go home / outing / rest).
;   - day_go_work  : shift on or imminent and not yet there -> a (go) travel act.
;
; Utility is trait-scaled (the ruling-10 disposition factor): base 80 x
; (0.75 + 0.5 x industriousness) -> 60..100. The shirker's 60 loses the
; supper crossing early (and even to a long lunch); the driven man's 100
; works through the meal windows and only night sleep (100) or exhaustion
; pulls him off the shift. Leisure/vice (~30) and the rest fallback stay
; dominated for everyone.
; ----------------------------------------------------------------------------

; Both rungs are MAINTENANCE rungs. Each (when) binds ?hours, the working hours on or about
; to be, as an ONSET step: wrapped in (latch-eval ...) it runs at the fire and is SKIPPED on the
; held re-check (which restores the fire-time binding). The CONTINUOUS gates (spatial @self
; building + on-shift, re-read live against the stashed hours) then own the cease: the held
; re-check ends the goal the cycle a gate drops (shift end, or leaving the workplace).

(driver day-work
  (role @self {@self industriousness ?industriousness}
    (role ?job {@self job ?job}
    (role ?org {?job org ?org}           ; PRODUCED-RESTRICTED: ?org threaded off ?job (unified)
               {?org workplace ?wp}       ; ?wp binds at fire
      (when (latch-eval (current-shift ?job): ?hours)
            (latch-eval (or (spatial @self building ?wp) (spatial @self space ?wp)))                  ; onset: the day's work starts on ARRIVAL, then survives every excursion
            (on-shift ?hours))
      (declare-utility duty (* (k-work-drive-value) (* (clamp (+ 1.0 (delib-ctr ?industriousness (k-drive-trait-swing))) 0.0 2.0)
                                                 (clamp (+ 1.0 (delib-ctrc (any {@self stress ?=0.5}).target (- 0.0 (k-drive-mood-swing)))) 0.0 2.0))))
      ; SPAWN the day's WORK TASK (tasks/work-task.mc): its performance tries fan the shift
      ; into the held duties' tasks and the between-duties post-stay; shift_over concludes it.
      ; MAINTAINED on the shift window alone: arrival is latched at onset, so leaving for an
      ; errand never withdraws the day's work.
      (effects       (maintain-proposal {@self work ?wp})
                     (set-shift-end-alarm ?hours))))))

; The work TASK's performance tries (at_post_morning / at_post_afternoon / shift_over) live
; in tasks/work-task.mc. day-go-to-work below stays a DRIVER (no task gate).

(driver day-go-to-work
  ; Shift on or imminent and not yet at the workplace: go there. The workplace ?wp may be a
  ; premises BUILDING (shop / office) or a ROOM (a gentleman's home study / back-office); go-to
  ; reaches either - the building first, then the room.
  (role ?job {@self job ?job}
    (role ?org {?job org ?org}           ; PRODUCED-RESTRICTED: ?org threaded off ?job (unified)
               {?org workplace ?wp}       ; ?wp binds at fire
               (not (or (spatial @self building ?wp) (spatial @self space ?wp)))             ; RESIDUAL: threaded gate, re-checked at the when-seam (incl. hold)
               -{@self work ?wp}          ; out on the day's work's own errand is not absent
      (when (latch-eval (current-shift ?job): ?hours)
            (on-shift ?hours))
      (declare-utility duty)
      (effects       (maintain-proposal {@self go-to ?wp})
                     (set-shift-end-alarm ?hours)))))
