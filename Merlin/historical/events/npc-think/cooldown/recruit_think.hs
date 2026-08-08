; ----------------------------------------------------------------------------
; recruit - the ORG side of the labour market (worker side: job_search_think.hs;
; clerical acts: recruit_actions.hs). Driven by the recruit_staff DUTY (duties_think.hs
; assigns it) - never by job kind or rank.
;
;   TASK recruit_staff ?org   the PERFORMANCE of the held recruit_staff duty
;                          ({@self duty_to ?org [k recruit_staff]} is the obligation;
;                          the running task is doing it). SPAWNED by the running work
;                          task (recruit_root) while the wage book is short of the
;                          org's authored headcount; CONCLUDED by recruit_done when
;                          the book fills. Rungs: post an advert; SWEEP the
;                          back-office inbox - offer the top applicant, reject the
;                          rest, destroy every application (gather_applications);
;                          take the filled posting off the board.
;
; The seeker's whole lifecycle rides HIS apply_for task outcome (offer_letter -> succ,
; rejection_letter -> fail), so the officer keeps no per-application state: one sweep act
; resolves the entire inbox, and the applications are destroyed so nothing accumulates.
; Households are excluded (their staffing is the bespoke staff_household lane).
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; --- the duty spawner: the running WORK task fans into the held duty ------------
; The /pres + has-proposal gates cover the spawn-to-promotion window; the duty
; task then owns itself (begin-proposal - it survives the work task's excursions
; to the board and its evening end), and recruit_done concludes it.
(npc-think recruit_root
  (task {@self work ?})
  (rng-stream employment)
  (role ?org (believes {@self duty_to ?org [k recruit_staff]})
             (not (believes {?org isa [k org household]}))
             (not (believes {@self recruit_staff ?org /pres}))
             (believes {?org record ?art}))
  (when (and (not (has-proposal {@self recruit_staff ?org}))
             (read-doc-record [k articles_of_incorporation] ?art (kind ?ok) (register ?reg))
             (< (count-doc-records [k employee_register] ?reg)
                (lookup public_orgs kind ?ok employee_count 2))))
  (utility 76)
  (effects (debug-print "RC_ROOT")
           (begin-proposal {@self recruit_staff ?org})))

; Outcome twin: the wage book reached the org's authored headcount - the duty
; performance concluded (the standing OBLIGATION {@self duty_to ..} remains).
(npc-think recruit_done
  (task {@self recruit_staff ?org}:?rec)
  (when (and (believes {?org record ?art})
             (read-doc-record [k articles_of_incorporation] ?art (kind ?ok) (register ?reg))
             (>= (count-doc-records [k employee_register] ?reg)
                 (lookup public_orgs kind ?ok employee_count 2))))
  (effects (set-outcome ?rec succ)))

; --- advertise: no live advert of mine for this org -> post one -----------------
(npc-think advertise_pick
  (task {@self recruit_staff ?org})
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
  (task {@self recruit_staff ?org})
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
; No cooldown: the one task-gate push arms it for the task's whole life (the
; activation persists and re-attempts per deliberation); the PILE is the gate -
; the sweep act destroys every application, the top read falls empty, the bout
; ceases and re-arms for the next batch. A cooldown here is the window-boundary
; sampling trap: its no-fire round (the officer home at midnight) re-cools
; forever.
(npc-think gather_applications
  (task {@self recruit_staff ?org})
  (when (and (believes {?org record ?art})
             (read-doc-record [k articles_of_incorporation] ?art (building ?wp))
             (in-building ?wp)
             (is-entity (mail-pile (room-of ?wp [k back_office])))
             (is-entity (attr (mail-pile (room-of ?wp [k back_office])) top))))
  ; The VERDICTS are decided here (the top applicant is offered, the rest
  ; rejected) and the letters written as this think's own effects - there is
  ; no clerical act body; the officer's desk presence is the work task's
  ; at_post dwell.
  (effects
    (debug-print "RC_SWEEP")
    (bind (room-of ?wp [k back_office]) ?office)
    (bind (attr (mail-pile ?office) top) ?top)
    (for-each ?app (attr-values (mail-pile ?office) items [k application])
      (do
        (read-doc-record [k application] ?app (applicant ?w))
        (if (= ?app ?top)
            (then
              (debug-print "RC_OFFER")
              (create-entity [k offer_letter]
                  (qual location (mail-space (home-of ?w))) (bind ?ol))
              (file-in-stack ?ol (mail-space (home-of ?w))))
            (else
              (create-entity [k rejection_letter]
                  (qual location (mail-space (home-of ?w))) (bind ?rl))
              (file-in-stack ?rl (mail-space (home-of ?w)))))
        (destroy-entity ?app)))))

; --- the filled posting comes off the board -------------------------------------
(npc-think take_down_filled
  ; ?ad ENUMERATED: an officer can hold several posted adverts at once, and a
  ; single @self bind would take the first post found and only ever test THAT
  ; ad's org - a filled org behind the second ad would never come down.
  (role ?ad (believes {@self post ?ad ?org}))
  (when (and (believes {?org record ?art})
             (read-doc-record [k articles_of_incorporation] ?art (kind ?ok) (register ?reg))
             (>= (count-doc-records [k employee_register] ?reg)
                 (lookup public_orgs kind ?ok employee_count 2))))
  (utility 81)
  (effects (maintain-proposal {@self take_down ?ad})))

(npc-think take_down_done
  ; ?ad ENUMERATED for the same reason as take_down_filled: the concluded
  ; take_down must clear ITS OWN post, not whichever post binds first.
  (role ?ad (believes {@self post ?ad ?org}))
  (when (believes {@self take_down ?ad /succ}))
  (effects (end-belief {@self post ?ad ?org})))
