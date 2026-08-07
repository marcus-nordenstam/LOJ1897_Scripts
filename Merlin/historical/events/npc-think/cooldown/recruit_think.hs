; ----------------------------------------------------------------------------
; recruit - the ORG side of the labour market (worker side: job_search_think.hs;
; clerical acts: recruit_actions.hs). Driven by the recruit_staff DUTY (duties_think.hs
; assigns it) - never by job kind or rank.
;
;   TASK recruiting ?org   standing while the duty is held AND the wage book is short of
;                          the org's authored headcount. Rungs: post an advert; each work
;                          morning SWEEP the back-office inbox - offer the top applicant,
;                          reject the rest, destroy every application (gather_applications);
;                          take the filled posting off the board.
;
; The seeker's whole lifecycle rides HIS apply_for task outcome (offer_letter -> succ,
; rejection_letter -> fail), so the officer keeps no per-application state: one sweep act
; resolves the entire inbox, and the applications are destroyed so nothing accumulates.
; Households are excluded (their staffing is the bespoke staff_household lane).
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
  (effects (debug-print "RC_ROOT")
           (maintain-proposal {@self recruiting ?org})))

; --- advertise: no live advert of mine for this org -> post one -----------------
(npc-think advertise_pick
  (task {@self recruiting ?org})
  (when (not (believes {@self post ? ?org})))
  (utility 79)
  (effects (debug-print "RC_ADPICK") (maintain-proposal {@self advertise ?org})))

(npc-think advertise_go
  (task {@self advertise ?org})
  (when (and (bind (find-building [k building church]) ?board)
             (not (in-building ?board))))
  (utility 81)
  (effects (maintain-proposal {@self enter ?board})))

; The post to advertise is the org's DISCLOSED staff role (org_staffing). The act's target
; is the org's ARTICLES (paper - an org can never ride an act); the role rides the aux.
(npc-think advertise_post
  (task {@self advertise ?org})
  (when (and (believes {?org record ?art})
             (bind (find-building [k building church]) ?board)
             (in-building ?board)
             (read-doc-record [k articles_of_incorporation] ?art (kind ?ok))
             (bind (lookup org_staffing org_kind ?ok staff_role none) ?jk)
             (is-kind ?jk)))
  (utility 81)
  (effects (debug-print "RC_ADPOST") (maintain-proposal {@self post_advert ?art ?jk})))

; POST-ACT: the advert paper exists -> book-keep {@self post ?ad ?org}, closing
; advertise_pick's dedup and ending the advertise subtask.
(npc-think advertise_done
  (task {@self advertise ?org})
  (role ?ad [k job_description]
            (not (believes {@self post ?ad ?}))
            (select (policy first-match)))
  (when (and (believes {?org record ?art})
             (believes {@self post_advert ?art /succ})
             (read-doc-record [k job_description] ?ad (find org_record ?art))))
  (effects (begin-belief {@self post ?ad ?org})))

; --- go to the workplace to process the inbox (the officer is not routed there by
; work_attendance - org heads hold no shift), then sweep it -------------------------
(npc-think gather_go
  (task {@self recruiting ?org})
  (when (and (believes {?org record ?art})
             (read-doc-record [k articles_of_incorporation] ?art (building ?wp))
             (not (in-building ?wp))
             (is-entity (mail-pile (room-of ?wp [k back_office])))))
  (utility 80)
  (effects (debug-print "RC_GATHERGO")
           (maintain-proposal {@self enter ?wp})))

; --- sweep the inbox: at the workplace, resolve the whole batch ---
; ONE act reads the back-office pile and offers the top applicant, rejects the rest, and
; destroys every application (recruit_actions.hs). No per-application state: the seeker's
; apply_for task outcome carries his side.
(npc-think gather_applications
  (cooldown 1 m)
  (task {@self recruiting ?org})
  (when (and (believes {?org record ?art})
             (read-doc-record [k articles_of_incorporation] ?art (building ?wp))
             (in-building ?wp)
             (is-entity (mail-pile (room-of ?wp [k back_office])))))
  (utility 82)
  (effects (debug-print "RC_SWEEP")
           (maintain-proposal {@self gather_applications ?art})))

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
