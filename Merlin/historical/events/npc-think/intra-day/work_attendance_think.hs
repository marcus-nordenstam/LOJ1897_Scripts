; ----------------------------------------------------------------------------
; work_attendance (npc-think lane) - the daily WORK-ATTENDANCE thinks. The
; shift-stay act lives in npc-act/work_attendance.hs.
;
; The labour market (employment.hs / business.hs / apprenticeship.hs) mints the
; employer/job beliefs but never moves anyone; THIS lane is what physically gets
; an employed NPC to their workplace during their shift and holds them there.
; Gated on the beliefs the labour market mints, all resolved live as composable
; belief reads: (bind {@self employer ?org}) (bind {?org workplace ?wp}) for the
; destination, and (bind {@self job ?job}) (bind {?job (work-hours-today-label)
; ?start ?end}) for today's shift hours. A missing employer / workplace / shift fails
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

; Both rungs stay LEVEL (schedule always), not the on-changed begin-goal + cease
; maintenance form. Each (when) binds TWO free vars off ONE shift belief -
; {?job <today's-shift-label> ?start ?end} - and (believes) binds only the target,
; never the aux, so ?end forces a (bind). That (bind) has nowhere re-eval-safe to go:
; a (role ?job ...) filter rejects it (its dynamic label AND aux field are both
; non-cacheable, so the role-object cache aborts the load), and a (bind) left in a
; maintenance (when) hard-errors once the rung holds - the hold restores the fire-time
; bindings, so the re-evaluated (bind) sees an already-bound pattern. With no
; re-eval-safe multi-var bind available, the faithful cadence is (schedule always) +
; (excl-goal ...): the per-cycle intra-day sweep ends the goal the cycle a gate drops
; (shift end, the lunch band, or arrival at the workplace).

(npc-think day_work
  (schedule always)
  (fatigue-timeout 0)              ; a work shift is not a fruitless search - never fatigue-capped
  (role ?org (believes {@self employer ?org})
             (believes {?org workplace ?wp}))   ; ?wp binds at fire
  (role ?job (believes {@self job ?job}))
  (when (and (bind {?job (work-hours-today-label) ?start ?end})
             (at-workplace ?wp)
             (or (in-work-hours ?start ?end) (work-starts-soon ?start ?end))))
  (utility (* 80 (factors (attr @self industriousness) 0.75 0.5)))
  ; The stay YIELDS at the workplace lunch band (12-14): eligibility is only
  ; sampled at act completions, so an uncapped shift-long stay would leap
  ; clean over work_lunch's window. After lunch the next 12:00 is tomorrow
  ; (a huge cap), so the stay runs to shift end.
  (effects (excl-goal {@self work ?wp})))

(npc-think day_go_to_work
  ; Shift on or imminent and not yet at the workplace: mint {@self enter ?wp} and the
  ; generic enter chain (enter.hs) routes the travel. Level for the shared shift-hours
  ; bind blocker documented above.
  (schedule always)
  (fatigue-timeout 0)              ; commuting to work is not a fruitless search - never fatigue-capped
  (role ?org (believes {@self employer ?org})
             (believes {?org workplace ?wp}))   ; ?wp binds at fire
  (role ?job (believes {@self job ?job}))
  (when (and (bind {?job (work-hours-today-label) ?start ?end})
             (or (in-work-hours ?start ?end) (work-starts-soon ?start ?end))
             (not (at-workplace ?wp))))
  (utility (* 80 (factors (attr @self industriousness) 0.75 0.5)))
  (effects (excl-goal {@self enter ?wp})))
