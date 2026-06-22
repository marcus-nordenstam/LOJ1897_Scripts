; ----------------------------------------------------------------------------
; work_attendance - the daily WORK-ATTENDANCE lane (npc-act).
;
; The labour market (employment.hs / business.hs / apprenticeship.hs) mints the
; employer/job beliefs but never moves anyone; THIS lane is what physically gets
; an employed NPC to their workplace during their shift and holds them there.
; Gated on the employer belief the labour market already mints - resolved live as the
; two-hop (bind-target {@self employer ?org}) (bind-target {?org workplace ?wp}); a
; missing employer/workplace fails the gate (no job -> no commute). Plus the
; per-weekday shift hours stamped at hire.
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
  (when (and (bind-target {@self employer ?org})
             (bind-target {?org workplace ?wp})
             (self-at ?wp)
             (or (in-work-hours @self) (work-starts-soon @self))))
  (utility 80)
  (effects (stay (minutes-until-shift-end @self))))

(hsim-event day_go_to_work
  (intra-day)
  (nl   "@self sets out for work")
  (when (and (bind-target {@self employer ?org})
             (bind-target {?org workplace ?wp})
             (or (in-work-hours @self) (work-starts-soon @self))
             (not (self-at ?wp))))
  (utility 80)
  (effects (go @self ?wp)))
