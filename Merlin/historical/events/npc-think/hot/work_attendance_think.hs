; ----------------------------------------------------------------------------
; work_attendance (npc-think lane) - the daily WORK-ATTENDANCE thinks. The
; shift-stay act lives in npc-act/work_attendance.hs.
;
; The labour market (employment.hs / business.hs / apprenticeship.hs) mints the
; job beliefs but never moves anyone; THIS lane is what physically gets
; an employed NPC to their workplace during their shift and holds them there.
; Gated on the beliefs the labour market mints, all resolved live as composable
; belief reads: (bind {@self job.org ?org}) (bind {?org workplace ?wp}) for the
; destination, and (bind {@self job ?job}) (bind {?job (work-hours-today-label)
; ?start ?end}) for today's shift hours. A missing job / workplace / shift fails
; the gate (no job, or a day off -> no commute). The shift clock-math ops then test
; the bound ?start / ?end against the env clock.
;
; Two intra-day rules competing by (utility); the intra-day deliberation commits
; the max-utility eligible act:
;   - day_work     : already AT the workplace during/just-before the shift -> a
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

; Both rungs are MAINTENANCE rungs. Each (when) binds TWO free vars off ONE
; shift belief - {?job <today's-shift-label> ?start ?end} - and (believes) binds only the target,
; never the aux, so ?end forces a (bind). That (bind) is an ONSET step: it derives today's shift
; hours at the fire. Wrapped in (latch-eval ...) it runs at the fire (binding ?start/?end into
; the stash) and is SKIPPED on the held re-check (which restores the fire-time bindings), so it
; never re-errors on an already-bound pattern. The CONTINUOUS gates (at-workplace + in-work-hours,
; re-read live against the stashed shift) then own the cease: the held re-check ends the
; goal the cycle a gate drops (shift end, or leaving the workplace).

(npc-think day_work
  (fatigue 0)                      ; a work shift is not a fruitless search - never fatigue-capped
  (role ?job {@self job ?job})
  (role ?org {?job org ?org}           ; PRODUCED-RESTRICTED: ?org threaded off ?job (unified)
             (believes {?org workplace ?wp})       ; ?wp binds at fire
             (at-workplace ?wp))                    ; RESIDUAL: threaded gate, re-checked at the when-seam (incl. hold)
  (when (latch-eval (bind {?job (work-hours-today-label) ?start ?end}))  ; onset: derive the shift, bind ?start/?end
        (and (not (believes {@self work ?wp /pres}))
             (not (has-proposal {@self work ?wp}))
             (or (in-work-hours ?start ?end) (work-starts-soon ?start ?end))))
  (utility 80)
  ; SPAWN the day's WORK TASK (a bodyless umbrella, never an action): its performance
  ; rungs fan the shift into the held duties' tasks (recruit_think recruit_root) and
  ; the between-duties post-stay (at_post below); shift_over concludes it. begin (not
  ; maintain): the task survives lunch, errands to the board and every excursion -
  ; interrupted tasks resume; the /pres + has-proposal gates cover the spawn window.
  (effects       (begin-proposal {@self work ?wp})))

; Between duties: BE at the post - the PRE-LUNCH and POST-LUNCH dwell blocks,
; each aimed at its ABSOLUTE boundary (the aux is an until-hour, so a dwell
; interrupted by a duty errand resumes toward the SAME boundary). The lowest
; job utility: any duty task outbids it. Each rung's (when) window fells its
; bout at the boundary, so the afternoon block always re-fires with a fresh
; ?until.
(npc-think at_post_morning
  (task {@self work ?wp})
  (role ?job {@self job ?job})
  (when (latch-eval (bind {?job (work-hours-today-label) ?start ?end}))
        (and (in-building ?wp) (< (now-hour) 12)))
  (utility 78)
  (effects (maintain-proposal {@self dwell ?wp (min 12 ?end)})))

(npc-think at_post_afternoon
  (task {@self work ?wp})
  (role ?job {@self job ?job})
  (when (latch-eval (bind {?job (work-hours-today-label) ?start ?end}))
        (and (in-building ?wp) (>= (now-hour) 12)))
  (utility 78)
  (effects (maintain-proposal {@self dwell ?wp ?end})))

; Outcome twin: the shift is over (outside both the working window and the
; starts-soon spawn band) - the day's work concluded.
(npc-think shift_over
  (task {@self work ?wp}:?w)
  (role ?job {@self job ?job})
  (when (latch-eval (bind {?job (work-hours-today-label) ?start ?end}))
        (not (or (in-work-hours ?start ?end) (work-starts-soon ?start ?end))))
  (effects (set-outcome ?w succ)))

(npc-think day_go_to_work
  ; Shift on or imminent and not yet at the workplace: mint {@self enter ?wp} and the
  ; generic enter chain (enter.hs) routes the travel. Ceases on arrival (at-workplace) or shift end.
  (fatigue 0)                      ; commuting to work is not a fruitless search - never fatigue-capped
  (role ?job {@self job ?job})
  (role ?org {?job org ?org}           ; PRODUCED-RESTRICTED: ?org threaded off ?job (unified)
             (believes {?org workplace ?wp})       ; ?wp binds at fire
             (not (at-workplace ?wp)))             ; RESIDUAL: threaded gate, re-checked at the when-seam (incl. hold)
  (when (latch-eval (bind {?job (work-hours-today-label) ?start ?end}))  ; onset: derive the shift, bind ?start/?end
        (or (in-work-hours ?start ?end) (work-starts-soon ?start ?end)))
  (utility 80)
  (effects       (maintain-proposal {@self enter ?wp})))
