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
;                          heard acceptance, take the filled posting down.
;
; The ACTS are pure paper effects; ALL recruiter bookkeeping (posted / recorded /
; heard-copy ends) is minted HERE, in *_done think rules gated on the act's
; outcome ({act /succ} - conclusive outcome implies /past) or on the paper the
; act produced - the isim get/give post-action pattern. Every *_done rung NESTS
; inside its still-running parent task (advertise / recruiting / posted), so a
; concluded act never accumulates standing activations: when the task ends, its
; post-act rungs go with it. The org object stays strictly in the think realm:
; acts carry only paper and people.
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
; proposal's aux. The act's target is the org's ARTICLES (paper - an org can
; never ride an act).
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
  (effects
    (debug-print "TRACE-ADVERTISE org=?org jk=?jk ok=?ok")
    (if (is-kind ?jk)
        (then (maintain-proposal {@self post_advert ?art ?jk})))))

; POST-ACT: the advert paper exists (perceived at the board) and its org_record
; backlink names my org's articles -> book-keep {@self posted ?ad ?org}, which
; closes advertise_pick's dedup and ends the advertise subtask.
(npc-think advertise_done
  (role ?org (believes {@self advertise ?org})
             (believes {?org record ?art}))
  (role ?ad [k job_description]
            (not (believes {@self posted ?ad ?})))
  (when (and (believes {@self post_advert ?art /succ})
             (read-doc-record [k job_description] ?ad (find org_record ?art))))
  (effects (begin-belief {@self posted ?ad ?org})))

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
  (effects (debug-print "TRACE-APPHEARD cand=?cand wp=?wp")
           (maintain-proposal {@self record_applicant ?cand})))

; POST-ACT: the row is on paper -> book-keep the applicant as recorded and close
; the heard apply_for copy, so a later re-application is heard fresh.
(npc-think record_done
  (role ?org (believes {@self recruiting ?org}))
  (role ?cand (any_human ?cand)
              (believes {?cand apply_for ?})
              (not (believes {@self recorded ?cand}))
              (select (policy first-match)))
  (when (and (believes {?cand apply_for ?jk})
             (believes {@self record_applicant ?cand /succ})))
  (effects
    (debug-print "TRACE-RECORDED cand=?cand jk=?jk")
    (begin-belief {@self recorded ?cand})
    (end-belief {?cand apply_for ?jk})))

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
  (effects
    (debug-print "TRACE-HIREDECIDE win=?win merit=?m")
    (if (is-entity ?win)
        (then (maintain-proposal {@self send_letters ?appdoc ?win})))))

; --- enrol the accepted hire: the wage book (?reg) is derived HERE, in the think -
(npc-think acceptance_heard
  (role ?org (believes {@self recruiting ?org})
             (believes {?org record ?art}))
  (role ?cand (any_human ?cand)
              (believes {?cand accept_of ?})
              (select (policy first-match)))
  (when (and (believes {?org workplace ?wp})
             (in-building ?wp)
             (read-doc-record [k articles_of_incorporation] ?art (register ?reg))))
  (utility 82)
  (effects (maintain-proposal {@self enrol ?cand ?reg})))

; POST-ACT: the hire is on the wage book -> close the heard acceptance copy and
; the recorded mark (the man is staff now, not an applicant). NESTED in the
; recruiter's own {@self recorded ?cand} round-context, NOT the recruiting task:
; the enrol act is what FILLS the roster, so recruiting's falling edge races this
; cleanup - recorded is the context this rung itself closes.
(npc-think enrol_done
  (role ?cand (any_human ?cand)
              (believes {?cand accept_of ?})
              (believes {@self recorded ?cand})
              (select (policy first-match)))
  (when (and (believes {?cand accept_of ?jk})
             (believes {@self enrol ?cand /succ})))
  (effects
    (end-belief {?cand accept_of ?jk})
    (end-belief {@self recorded ?cand})))

; --- the filled posting comes off the board --------------------------------------
; Standing while my advert is up AND the wage book shows the org at strength:
; the position is filled, so take the paper down (recruit_root's vacancy test,
; inverted).
(npc-think take_down_filled
  (role @self (believes {@self posted ?ad ?org}))
  (when (and (believes {?org record ?art})
             (read-doc-record [k articles_of_incorporation] ?art (kind ?ok) (register ?reg))
             (>= (count-doc-records [k employee_register] ?reg)
                 (lookup public_orgs kind ?ok employee_count 2))))
  (utility 81)
  (effects (maintain-proposal {@self take_down ?ad})))

; POST-ACT: the paper is gone -> close the posted book-keeping (which also ends
; take_down_filled's own guard).
(npc-think take_down_done
  (role @self (believes {@self posted ?ad ?org}))
  (when (believes {@self take_down ?ad /succ}))
  (effects (end-belief {@self posted ?ad ?org})))
