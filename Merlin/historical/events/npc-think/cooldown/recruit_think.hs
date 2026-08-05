; ----------------------------------------------------------------------------
; recruit - the ORG side of the labour market (the worker side lives in
; job_search_think.hs; the clerical acts in recruit_actions.hs). Driven by the
; recruit_staff DUTY (duties_think.hs assigns it) - never by job kind or rank.
;
;   TASK recruit ?org      standing while the duty is held AND the wage book is
;                          short of the org's authored headcount. Rungs: post an
;                          advert (advertise subtask), read the applications left
;                          at the workplace, make ONE offer + reject the rest,
;                          enrol the accepted hire, take the filled posting down.
;
; The applicants are physical `application` documents the seekers leave at the
; workplace; the recruiter READS the pile and drives ONE `status` field per paper
; (offered | rejected), plus a reply letter. All recruiter bookkeeping (post /
; offering) is minted HERE, in *_done think rules gated on the act outcome ({act
; /succ}) or on the paper the act produced. The org object stays strictly mental:
; acts carry only paper and people. Households are excluded (their staffing is the
; bespoke staff_household lane).
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
             (not (believes {@self post ? ?org})))
  (utility 79)
  (effects (maintain-proposal {@self advertise ?org})))

(npc-think advertise_go
  (role ?org (believes {@self advertise ?org}))
  (when (and (bind (find-building [k building church]) ?board)
             (not (in-building ?board))))
  (utility 81)
  (effects (maintain-proposal {@self enter ?board})))

; The post to advertise is the org's DISCLOSED staff role (org_staffing) - the
; occupation it needs, and only that. The act's target is the org's ARTICLES
; (paper - an org can never ride an act); the role rides the aux.
(npc-think advertise_post
  (role ?org (believes {@self advertise ?org})
             (believes {?org record ?art}))
  (when (and (bind (find-building [k building church]) ?board)
             (in-building ?board)
             (read-doc-record [k articles_of_incorporation] ?art (kind ?ok))
             (bind (lookup org_staffing org_kind ?ok staff_role none) ?jk)
             (is-kind ?jk)))
  (utility 81)
  (effects
    (debug-print "TRACE-ADVERTISE org=?org jk=?jk ok=?ok")
    (maintain-proposal {@self post_advert ?art ?jk})))

; POST-ACT: the advert paper exists (its org_record backlinks my articles) ->
; book-keep {@self post ?ad ?org}, closing advertise_pick's dedup and ending the
; advertise subtask.
(npc-think advertise_done
  (role ?org (believes {@self advertise ?org})
             (believes {?org record ?art}))
  (role ?ad [k job_description]
            (not (believes {@self post ?ad ?}))
            (select (policy first-match)))
  (when (and (believes {@self post_advert ?art /succ})
             (read-doc-record [k job_description] ?ad (find org_record ?art))))
  (effects (begin-belief {@self post ?ad ?org})))

; --- read the applications left at the workplace --------------------------------
; A submitted application paper, perceived at my desk and not yet read -> read its
; record into my mind (status + workplace scope the decision rungs).
(npc-think application_read
  (role ?org (believes {@self recruiting ?org})
             (believes {?org workplace ?wp}))
  (role ?app [k application]
            (not (believes {?app status ?}))
            (select (policy first-match)))
  (when (and (co-present @self ?app)
             (read-doc-record [k application] ?app (status ?st) (workplace ?awp))))
  (effects
    (debug-print "TRACE-APPREAD app=?app st=?st")
    (begin-belief {?app workplace ?awp})
    (begin-belief {?app status ?st})))

; --- the decision: offer ONE applied candidate, no offer already outstanding ----
; The choice IS the recruiter's mental act, so `offered` + `offering` are minted
; here (like begin-goal in a decision think); the make_offer ACT is the physical
; consequence - it stamps the paper and posts the reply letter that reaches the
; seeker. `offering` blocks a second offer for the same seat until the hire enrols.
(npc-think hire_decide
  (cooldown 2 m)
  (rng-stream employment)
  (role ?org (believes {@self recruiting ?org})
             (not (believes {@self offering ? ?org})))
  (role ?app [k application]
            (believes {?app status [k applied]})
            (believes {?app workplace ?wp})
            (select (policy first-match)))
  (when (believes {?org workplace ?wp}))
  (utility 82)
  (effects
    (debug-print "TRACE-HIREDECIDE app=?app")
    (begin-belief {?app status [k offered]})
    (begin-belief {@self offering ?app ?org})
    (maintain-proposal {@self make_offer ?app})))

; --- reject the also-rans: every still-applied paper once an offer is out --------
(npc-think reject_loser
  (role ?org (believes {@self recruiting ?org})
             (believes {@self offering ? ?org}))
  (role ?app [k application]
            (believes {?app status [k applied]})
            (believes {?app workplace ?wp})
            (select (policy first-match)))
  (when (believes {?org workplace ?wp}))
  (utility 82)
  (effects
    (debug-print "TRACE-REJECT app=?app")
    (begin-belief {?app status [k rejected]})
    (maintain-proposal {@self send_rejection ?app})))

; --- enrol the accepted hire: the paper reads accepted (the seeker signed) -------
(npc-think enrol_hire
  (role ?org (believes {@self recruiting ?org})
             (believes {?org record ?art})
             (believes {?org workplace ?wp}))
  (role ?app [k application]
            (believes {?app status [k offered]})
            (select (policy first-match)))
  (when (and (co-present @self ?app)
             (read-doc-record [k application] ?app (find status [k accepted]) (applicant ?w))
             (read-doc-record [k articles_of_incorporation] ?art (register ?reg))))
  (utility 82)
  (effects
    (debug-print "TRACE-ENROL app=?app w=?w")
    (maintain-proposal {@self enrol ?app ?reg})))

; POST-ACT: the hire is on the wage book -> the seat is filled; clear my offer.
(npc-think enrol_done
  (role ?org (believes {@self recruiting ?org}))
  (role ?app [k application]
            (believes {?app status [k offered]})
            (believes {@self offering ?app ?org})
            (select (policy first-match)))
  (when (and (read-doc-record [k application] ?app (find status [k accepted]))
             (believes {@self enrol ?app /succ})))
  (effects
    (begin-belief {?app status [k accepted]})
    (end-belief {@self offering ?app ?org})))

; --- the filled posting comes off the board -------------------------------------
(npc-think take_down_filled
  (role @self (believes {@self post ?ad ?org}))
  (when (and (believes {?org record ?art})
             (read-doc-record [k articles_of_incorporation] ?art (kind ?ok) (register ?reg))
             (>= (count-doc-records [k employee_register] ?reg)
                 (lookup public_orgs kind ?ok employee_count 2))))
  (utility 81)
  (effects (maintain-proposal {@self take_down ?ad})))

(npc-think take_down_done
  (role @self (believes {@self post ?ad ?org}))
  (when (believes {@self take_down ?ad /succ}))
  (effects (end-belief {@self post ?ad ?org})))
