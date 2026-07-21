; ----------------------------------------------------------------------------
; hire_errand - the npc-ACT half of the hiring split (Item 5, employee-side).
;
; The decision (employment.hs `hiring`) minted {@self goal {@self engage_staff
; <org_articles>}} on the WORKER. He presents himself at the firm and is engaged
; there - the hiring conducted in person at the premises. The org's articles are
; the goal focus, carried onto the act-belief's target at promotion, so the
; (when) binds them straight off {@self engage_staff ?art}.
;
; The eligibility MATCH is the (select-record ...) over the occupations table
; (hiring_macros.hs gates + score; the old C++ occupation_match is gone): among
; the posts this org hosts, the best-scoring one @self is eligible for. (else
; fail) keeps the interview act completing even when nothing here fits - ?jk
; binds @fail, no hire, the goal clears, and the seeker tries elsewhere via the
; monthly re-target. Acceptance is score-gated at the interview ((chance ...) in
; the effects - a marginal fit may not be taken this time).
; ----------------------------------------------------------------------------

(npc-act engage_staff_act
  (when (and (bind {@self engage_staff ?art})
             (read-doc-record [k articles_of_incorporation] ?art (kind ?ok))))
  (duration 45)
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
  (act-effects
    (if (and (is-kind ?jk)
             (chance (min 0.95 (job-match-score ?t1 ?w1 ?t2 ?w2))))
      (hire-seq ?art ?jk [k apprentice]))
    (end-act {@self engage_staff})))
