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

(npc-think day_work
  (short-term-think)
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
  (cont-fire-effects (excl-goal {@self work ?wp})))

(npc-think day_go_to_work
  ; The (when) binds TWO free vars (?start ?end) via one belief - believes binds only the
  ; target, not the aux, so this needs (bind ...), which errors when a maintenance (when) is
  ; re-evaluated. So this rung stays LEVEL-triggered for now; go-into -> the enter chain. The
  ; target-form conversion here waits for a multi-var re-eval-safe bind (§5.8 vicinity).
  (short-term-think)
  (fatigue-timeout 0)              ; commuting to work is not a fruitless search - never fatigue-capped
  (role ?org (believes {@self employer ?org})
             (believes {?org workplace ?wp}))   ; ?wp binds at fire
  (role ?job (believes {@self job ?job}))
  (when (and (bind {?job (work-hours-today-label) ?start ?end})
             (or (in-work-hours ?start ?end) (work-starts-soon ?start ?end))
             (not (at-workplace ?wp))))
  (utility (* 80 (factors (attr @self industriousness) 0.75 0.5)))
  (cont-fire-effects (excl-goal {@self enter ?wp})))
