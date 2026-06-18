; ----------------------------------------------------------------------------
; work_attendance - the daily WORK-ATTENDANCE lane (npc-act).
;
; The labour market (employment.hs / business.hs / apprenticeship.hs) mints the
; employer/job beliefs but never moves anyone; THIS lane is what physically gets
; an employed NPC to their workplace during their shift and holds them there.
; Promoted out of the retired day_shape scaffold (rules 1-2), gated on the
; employer belief the labour market already mints (`has-job`) + the per-weekday
; shift hours stamped at hire.
;
; Two intra-day cascade rules competing by (utility); the cascade commits the
; max-utility eligible act:
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
  (when (and (self-at (workplace-of @self))
             (or (in-work-hours @self) (work-starts-soon @self))))
  (utility 80)
  (effects (stay (minutes-until-shift-end @self))))

(hsim-event day_go_to_work
  (intra-day)
  (nl   "@self sets out for work")
  (when (and (has-job @self)
             (or (in-work-hours @self) (work-starts-soon @self))
             (not (self-at (workplace-of @self)))))
  (utility 80)
  (effects (go @self (workplace-of @self))))
