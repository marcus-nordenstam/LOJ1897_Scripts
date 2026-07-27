; ----------------------------------------------------------------------------
; recruit - the ORG side of the labour market (the worker side lives in
; job_search_think.hs; the clerical acts in recruit_actions.hs). Driven by the
; recruit_staff DUTY (duties_think.hs assigns it) - never by job kind or rank.
;
;   TASK recruit ?org      standing while the duty is held AND the wage book is
;                          short of the org's authored headcount. Rungs: post an
;                          advert (advertise subtask), record heard applications,
;                          decide after ~2 months (DOC argmax over the applicants
;                          book), send offer + rejection letters, enrol on the
;                          heard acceptance (and take the advert DOWN - the
;                          position is filled).
;
; Every input is a heard say, a letter or a public document - no mind reads.
; Households are excluded: their staffing is the bespoke staff_household lane.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; --- the standing recruitment task: duty + vacancy ------------------------------
(npc-think recruit_root
  (cooldown 1 m)
  (rng-stream employment)
  (role ?org (believes {@self duty_to ?org [k recruit_staff]})
             (not (believes {?org isa [k org household]}))
             (believes {?org record ?art}))
  (when (and (read-doc-record [k articles_of_incorporation] ?art (kind ?ok) (register ?reg))
             (< (count-doc-records [k employee_register] ?reg)
                (lookup public_orgs kind ?ok employee_count 2))))
  (utility 76)
  (effects (maintain-proposal {@self recruiting ?org})))

; --- advertise: no live advert of mine for this org -> post one -----------------
(npc-think advertise_pick
  (role ?org (believes {@self recruiting ?org})
             (not (believes {@self posted ? ?org})))
  (utility 79)
  (effects (maintain-proposal {@self advertise ?org})))

(npc-think advertise_go
  (role ?org (believes {@self advertise ?org}))
  (when (and (bind (find-building [k building church]) ?board)
             (not (in-building ?board))))
  (utility 81)
  (effects (maintain-proposal {@self enter ?board})))

; The post to advertise is picked HERE (select-record is an event-level clause):
; the first staff occupation the org's kind hosts, carried to the act as the
; proposal's aux.
(npc-think advertise_post
  (role ?org (believes {@self advertise ?org})
             (believes {?org record ?art}))
  (when (and (bind (find-building [k building church]) ?board)
             (in-building ?board)
             (read-doc-record [k articles_of_incorporation] ?art (kind ?ok))))
  (select-record (table occupations)
    (bind job ?jk)
    (bind business_type ?bt)
    (bind may_own ?mo)
    (when (and (not (= ?mo true)) (hosted-by ?bt ?ok)))
    (score 1)
    (policy argmax)
    (else fail))
  (utility 81)
  ; The act targets the BOARD (physical - an org has no env entity); the act body
  ; re-derives the org from the actor's own running advertise task belief.
  (effects
    (if (is-kind ?jk)
        (then (maintain-proposal {@self post_advert ?board ?jk})))))

; --- record a heard application at the counter ----------------------------------
(npc-think application_heard
  (role ?org (believes {@self recruiting ?org}))
  (role ?cand (any_human ?cand)
              (believes {?cand apply_for ?})
              (not (believes {@self recorded ?cand}))
              (select (policy first-match)))
  (when (and (believes {?org workplace ?wp})
             (in-building ?wp)))
  (utility 82)
  (effects (maintain-proposal {@self record_applicant ?cand})))

; --- the decision, after ~2 months: best applicant per the book -----------------
; The DOC argmax over the applicants book (merit; the book's append order = the
; application order breaks ties). Proposes the letters act carrying the winner.
(npc-think hire_decide
  (cooldown 2 m)
  (rng-stream employment)
  (role ?org (believes {@self recruiting ?org}))
  (when (and (believes {?org workplace ?wp})
             (bind (believed-located [k job_application] ?wp) ?appdoc)
             (> (count-doc-records [k job_application] ?appdoc) 0)))
  (select-record (doc [k job_application] ?appdoc)
    (bind worker ?win)
    (bind merit ?m)
    (when (alive ?win))
    (score ?m)
    (policy argmax)
    (else fail))
  (utility 82)
  ; The act targets the applicants BOOK (physical); the winner rides the aux.
  (effects
    (if (is-entity ?win)
        (then (maintain-proposal {@self send_letters ?appdoc ?win})))))

; --- enrol the accepted hire -----------------------------------------------------
(npc-think acceptance_heard
  (role ?org (believes {@self recruiting ?org}))
  (role ?cand (any_human ?cand)
              (believes {?cand accept_of ?})
              (select (policy first-match)))
  (when (and (believes {?org workplace ?wp})
             (in-building ?wp)))
  (utility 82)
  (effects (maintain-proposal {@self enrol ?cand})))
