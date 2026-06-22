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
; Utility 80 dominates leisure/vice (~30) and the rest lane's mild fallback, but
; loses to night sleep (100). Trait-driven shirking (industriousness) is a
; follow-up - utility becomes a (factors ...) of industriousness then.
; ----------------------------------------------------------------------------

(hsim-event day_work
  (intra-day)
  (nl   "@self works")
  (when (and (bind {@self employer ?org})
             (bind {?org workplace ?wp})
             (bind {@self job ?job})
             (bind {?job (work-hours-today-label) ?start ?end})
             (self-at ?wp)
             (or (in-work-hours ?start ?end) (work-starts-soon ?start ?end))))
  (utility 80)
  (effects (stay (minutes-until-shift-end ?end))))

(hsim-event day_go_to_work
  (intra-day)
  (nl   "@self sets out for work")
  (when (and (bind {@self employer ?org})
             (bind {?org workplace ?wp})
             (bind {@self job ?job})
             (bind {?job (work-hours-today-label) ?start ?end})
             (or (in-work-hours ?start ?end) (work-starts-soon ?start ?end))
             (not (self-at ?wp))))
  (utility 80)
  (effects (go @self ?wp)))
