; ----------------------------------------------------------------------------
; hire_errand - the npc-ACT half of the hiring split (Item 5, employee-side).
;
; The decision (employment.hs `hiring`) minted {@self goal {@self engage_staff
; <org_articles>}} on the WORKER. He presents himself at the firm and is engaged
; there - the hiring conducted in person at the premises. The org's articles are
; the goal focus, so the firm is (articles-building (goal-focus engage_staff)) and
; the eligibility-match hire uses those articles directly.
;
;   hire_go     : hold the goal, not at the firm -> travel act to its premises.
;   hire_dwell  : hold the goal, AT the firm -> a short dwell (the interview).
;   hire_commit : completion (completion-only) - the eligibility-match hire + clears goal.
; ----------------------------------------------------------------------------

(npc-think hire_go
  (short-term-think)
  (goal {@self engage_staff})
  (when (and (articles-building (goal-focus engage_staff) ?venue)
             (not (in-building ?venue))))
  (utility 82)
  (cont-fire-effects (go-into ?venue)))

(npc-think hire_dwell
  (short-term-think)
  (goal {@self engage_staff})
  (when (and (articles-building (goal-focus engage_staff) ?venue)
             (in-building ?venue)))
  (utility 82)
  (cont-fire-effects (begin-goal {@self engage_staff})))

(npc-act engage_staff_act
  (when (believes {@self engage_staff}))
  (duration 45)
  (act-effects
    ; bind the org's articles to a plain ?var so it can serve as a {pattern} subject
    ; inside hire-seq (a macro arg used in a pattern must be a ?var, not an expr).
    (bind (goal-focus engage_staff) ?art)
    ; eligibility MATCH (C++: occupation catalog + career scan) binds ?jk = the
    ; matched scoped job kind ([k job <leaf>]) or @fail (a marginal fit may not be
    ; taken); the .hs hire-seq then mints the employment beliefs in @self's mind.
    (match-job /articles ?art /worker @self (bind ?jk))
    (if ?jk
      (hire-seq ?art ?jk [k apprentice]))
    (end-act {@self engage_staff})
    (end-goal {@self engage_staff})))
