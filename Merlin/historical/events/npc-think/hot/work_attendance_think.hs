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
  (role ?org (believes {@self job.org ?org})
             (believes {?org workplace ?wp}))   ; ?wp binds at fire
  (role ?job (believes {@self job ?job}))
  (when (latch-eval (bind {?job (work-hours-today-label) ?start ?end}))  ; onset: derive the shift, bind ?start/?end
        (at-workplace ?wp)
        (or (in-work-hours ?start ?end) (work-starts-soon ?start ?end)))
  (utility 80)
  ; PROPOSE the work-stay (act_body_purification): day_work's (when) - at the workplace + in/near
  ; the shift - IS the precondition, so this propose is the whole terminal. Each completion
  ; re-proposes while still on shift, so the stay resumes to shift end.
  (effects       (maintain-proposal {@self work ?wp})))

(npc-think day_go_to_work
  ; Shift on or imminent and not yet at the workplace: mint {@self enter ?wp} and the
  ; generic enter chain (enter.hs) routes the travel. Ceases on arrival (at-workplace) or shift end.
  (fatigue 0)                      ; commuting to work is not a fruitless search - never fatigue-capped
  (role ?org (believes {@self job.org ?org})
             (believes {?org workplace ?wp}))   ; ?wp binds at fire
  (role ?job (believes {@self job ?job}))
  (when (latch-eval (bind {?job (work-hours-today-label) ?start ?end}))  ; onset: derive the shift, bind ?start/?end
        (or (in-work-hours ?start ?end) (work-starts-soon ?start ?end))
        (not (at-workplace ?wp)))
  (utility 80)
  (effects       (maintain-proposal {@self enter ?wp})))
