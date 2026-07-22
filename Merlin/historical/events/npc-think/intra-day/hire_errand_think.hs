; ----------------------------------------------------------------------------
; hire_errand - the npc-THINK half of the hiring split (employee-side approach).
; The worker holds {@self engage_staff ?art}: travel to the firm, then, AT the firm,
; run the eligibility MATCH and propose the hire.
;
; act_body_purification: the eligibility (select-record) - which post the org hosts that
; @self is eligible for, and whether the interview lands - is DELIBERATION, so it lives
; here in hire_dwell (it used to sit inside engage_staff_act). When a post fits and the
; (chance) clears, PROPOSE {@self engage_staff ?art ?jk}; the dumb engage_staff_act then
; commits the hire off the ?art / ?jk carried on the proposal.
; ----------------------------------------------------------------------------

(npc-think hire_go
  (schedule on-commit)
  (if-blocked hold)
  (goal {@self engage_staff ?art})
  (role @self (not (believes {@self employer ?})))   ; once hired, stop; a lingering goal must not re-run the errand
  (when (and (articles-building ?art ?venue)
             (not (in-building ?venue))))
  (utility 82)
  (effects       (begin-goal {@self enter ?venue}))
  (cease-effects (end-goal   {@self enter ?venue})))

; AT the firm: run the eligibility MATCH over the occupations table (the old C++/act-body
; job-match) and, if a post fits and the interview lands, PROPOSE the hire. ?art is the org
; articles (bound off the goal target); ?ok its org kind. Re-proposed each decision point
; while dwelling (schedule always); once hired the (role @self (not (believes {@self employer
; ?}))) gate drops this rule (and the hiring minter's cease-effects ends the goal), so it stops.
(npc-think hire_dwell
  (schedule always)
  (goal {@self engage_staff ?art})
  (role @self (not (believes {@self employer ?})))   ; once hired, stop re-proposing (a lingering goal must not re-hire)
  (when (and (articles-building ?art ?venue)
             (in-building ?venue)
             (read-doc-record [k articles_of_incorporation] ?art (kind ?ok))))
  (select-record (table occupations)
    (bind job ?jk)
    (bind business_type ?bt)
    (bind may_own ?mo)
    (bind class_floor ?cf)
    (bind req_repute ?rr)
    (bind req_skill ?rsd)
    (bind req_skill_band ?rsb)
    (bind pref_trait1 ?t1)
    (bind pref_w1 ?w1)
    (bind pref_trait2 ?t2)
    (bind pref_w2 ?w2)
    (when (and (not (and (= ?mo true) (= ?bt none)))   ; founding-only posts are never hired
               (hosted-by ?bt ?ok)
               (class-ok @self ?cf)
               (repute-ok @self ?rr)
               (skill-ok @self ?rsd ?rsb)))
    (score (job-match-score ?t1 ?w1 ?t2 ?w2))
    (policy argmax)
    (else fail))
  (utility 82)
  (effects
    (if (and (is-kind ?jk)
             (chance (min 0.95 (job-match-score ?t1 ?w1 ?t2 ?w2))))
      (then (maintain-proposal {@self engage_staff ?art ?jk})))))
