; ----------------------------------------------------------------------------
; work_attendance - the daily WORK-ATTENDANCE lane (npc-act).
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

(hsim-event day_work
  (intra-day)
  (when (and (bind {@self employer ?org})
             (bind {?org workplace ?wp})
             (bind {@self job ?job})
             (bind {?job (work-hours-today-label) ?start ?end})
             (at-place ?wp)
             (or (in-work-hours ?start ?end) (work-starts-soon ?start ?end))))
  (utility (* 80 (factors (attr @self industriousness) 0.75 0.5)))
  ; The stay YIELDS at the workplace lunch band (12-14): eligibility is only
  ; sampled at act completions, so an uncapped shift-long stay would leap
  ; clean over work_lunch's window. After lunch the next 12:00 is tomorrow
  ; (a huge cap), so the stay runs to shift end.
  (effects (stay (min (minutes-until-shift-end ?end) (minutes-until-hour 12)))))

(hsim-event day_go_to_work
  (intra-day)
  (when (and (bind {@self employer ?org})
             (bind {?org workplace ?wp})
             (bind {@self job ?job})
             (bind {?job (work-hours-today-label) ?start ?end})
             (or (in-work-hours ?start ?end) (work-starts-soon ?start ?end))
             (not (at-place ?wp))))
  (utility (* 80 (factors (attr @self industriousness) 0.75 0.5)))
  (effects (go @self ?wp)))
