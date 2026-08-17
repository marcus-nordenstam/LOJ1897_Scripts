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
;                          the book fills. Rungs: post an advert; a daily office
;                          round that READS the office mail (read_mail - locate the
;                          mail room, duty-scan the applications addressed to the org
;                          into hand); RESOLVE the held batch (offer the first,
;                          reject the rest, destroy every application); take the
;                          filled posting off the board.
;
; The seeker's whole lifecycle rides HIS apply_for task outcome (offer_letter -> succ,
; rejection_letter -> fail), so the officer keeps no per-application state: one resolve
; act answers the whole held batch, and the applications are destroyed so nothing
; accumulates. Households are excluded (their staffing is the bespoke staff_household
; lane).
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; --- the duty spawner: the running WORK task fans into the held duty ------------
; ONE recruiting drive at a time: the lock admits a single activation; the duty
; task owns itself (begin-proposal - it survives the work task's excursions to the
; board and its evening end), and recruit_done concludes it.
(npc-think work_spawn_recruit_staff
  (lock-rule)
  (task {@self work ?})
  (rng-stream employment)
  (role ?org {@self duty_to ?org [k recruit_staff]}
             (not {?org isa [k org household]})
             (believes {?org record ?art}))
  (when (and (read-doc-record [k articles_of_incorporation] ?art (kind ?ok) (register ?reg))
             (< (count-doc-records [k employee_register] ?reg)
                (lookup public_orgs kind ?ok employee_count 2))))
  (utility duty)
  (effects (debug-print "RC_ROOT")
           (begin-proposal {@self recruit_staff ?org})))

; Outcome twin: the wage book reached the org's authored headcount - the duty
; performance concluded (the standing OBLIGATION {@self duty_to ..} remains).
(npc-think recruit_staff_done
  (task {@self recruit_staff ?org}:?rec)
  (when (and (any {?org record ?}).target: ?art
             (read-doc-record [k articles_of_incorporation] ?art (kind ?ok) (register ?reg))
             (>= (count-doc-records [k employee_register] ?reg)
                 (lookup public_orgs kind ?ok employee_count 2))))
  (effects (set-outcome ?rec succ)))

; --- advertise: no live advert of mine for this org -> post one -----------------
(npc-think recruit_staff_advertise
  (task {@self recruit_staff ?org})
  (when (none {@self post ? ?org}))
  (effects (debug-print "RC_ADPICK") (maintain-proposal {@self advertise ?org})))

(npc-think advertise_go
  (task {@self advertise ?org})
  (when (and (find-building [k building church]): ?board
             (not (in-building @self ?board))))
  (effects (maintain-proposal {@self enter ?board})))

; The post to advertise is the org's DISCLOSED staff role (org_staffing). The act's target
; is the org's ARTICLES (paper - an org can never ride an act); the role rides the aux.
(npc-think advertise_post
  (task {@self advertise ?org})
  (when (and (any {?org record ?}).target: ?art
             (find-building [k building church]): ?board
             (in-building @self ?board)
             (read-doc-record [k articles_of_incorporation] ?art (kind ?ok))
             (lookup org_staffing org_kind ?ok staff_role none): ?jk
             (is-kind ?jk)))
  (effects (debug-print "RC_ADPOST") (maintain-proposal {@self POST_ADVERT ?art ?jk})))

; POST-ACT: the advert paper exists -> book-keep {@self post ?ad ?org}, closing
; advertise_pick's dedup and ending the advertise subtask.
(npc-think advertise_done
  (task {@self advertise ?org})
  (role ?ad [k job_description]
            (not {@self post ?ad ?})
            (select (policy first-match)))
  (when (and (any {?org record ?}).target: ?art
             (any {@self POST_ADVERT ?art /succ} (out int))
             (read-doc-record [k job_description] ?ad (find org_record ?art))))
  (effects (begin-belief {@self post ?ad ?org})))

; --- the office round: the officer is not routed to the workplace by
; work_attendance (org heads hold no shift), so while the office inbox holds mail
; he goes himself and READS it - read_mail locates the mail room (wandering the
; premises if he does not yet know it), and its take_my_letters round lifts BOTH
; his personal mail and every application addressed to the recruiting duty he
; holds. The gate is the MORNING OFFICE ROUND: the officer cannot sense a full
; inbox from afar (stack contents are behaviour-revealed knowledge), so he
; checks it because it is his duty hour - an empty pile just concludes the
; round at the first look.
(npc-think recruit_staff_go_office
  (task {@self recruit_staff ?org})
  ; CADENCE, not clock: once since the last successful sweep (days-since-last,
  ; elapsed time - not a 9-11 time-of-day window, which the interruptible-dwell
  ; rhythm now slides the officer clean past). An empty pile concludes the round
  ; at the first look, so a wasted trip is cheap; the /succ read closes this for
  ; a day.
  (when (and (any {?org record ?}).target: ?art
             (read-doc-record [k articles_of_incorporation] ?art (building ?wp))
             (not (in-building @self ?wp))
             (>= (days-since-last {@self read_mail ?wp /succ}) 1)))
  ; obligation: the office round is EPISODIC (the daily duty round) and must
  ; override the daily need churn (meals preempt duty -> the maintain gate
  ; falls -> the trip resets forever; the bands-plan table files episodic
  ; overriding work under obligation).
  (utility obligation)
  (effects (debug-print "RC_GOOFC") (maintain-proposal {@self enter ?wp})))

(npc-think recruit_staff_read_mail
  (lock-rule)
  (task {@self recruit_staff ?org})
  (when (and (any {?org record ?}).target: ?art
             (read-doc-record [k articles_of_incorporation] ?art (building ?wp))
             (in-building @self ?wp)
             (>= (days-since-last {@self read_mail ?wp /succ}) 1)))
  ; go_office (not-in-building) and this (in-building) are mutually exclusive - they
  ; never compete - and the begun read_mail task inherits obligation and holds the
  ; chain, so a bare band is enough; no ordinal step-up needed.
  (utility obligation)
  (effects (debug-print "RC_RDMAIL") (begin-proposal {@self read_mail ?wp})))

; --- holding gathered applications -> carry them to a known outgoing pile (the
; verdicts are posted where they are written; any outbox serves - the magic mail
; service routes by written address).
(npc-think recruit_staff_resolve_go
  (task {@self recruit_staff ?org})
  (role ?home {@self home ?home})
  (role ?out [k outgoing_mail_stack] (not (co-present ?out @self)))
  (role ?app [k application] (spatial @self hold)
        (select (policy first-match)))
  (when (and (in-building ?out ?home)
             (location ?out): ?room))
  (utility obligation)
  (effects (debug-print "RC_RESGO") (maintain-proposal {@self WALK ?room})))

; --- holding gathered applications, standing at an outgoing pile -> run the
; verdict ROUND (resolve_applications_think.hs): iterate the held applications
; one drafting act at a time - offer the first, reject the rest - until the
; hands are empty. Any outgoing pile serves - the magic mail service routes
; each verdict by its written address.
(npc-think recruit_staff_resolve
  (lock-rule)
  (task {@self recruit_staff ?org})
  (role ?out [k outgoing_mail_stack] (co-present ?out @self))
  (role ?app [k application] (spatial @self hold)
        (select (policy first-match)))
  (when (none {@self resolve_applications ?out /pres}))
  (utility obligation)
  (effects (debug-print "RC_RESOLVE") (begin-proposal {@self resolve_applications ?out})))

; --- the filled posting comes off the board -------------------------------------
(npc-think take_down_filled
  ; ?ad ENUMERATED: an officer can hold several posted adverts at once, and a
  ; single @self bind would take the first post found and only ever test THAT
  ; ad's org - a filled org behind the second ad would never come down. The free
  ; ?org aux PRODUCES off the enumerated ad's own post belief (the uniform field
  ; rule; deterministic - the post aux is @excl).
  (role ?ad (believes {@self post ?ad ?org}))
  (when (and (any {?org record ?}).target: ?art
             (read-doc-record [k articles_of_incorporation] ?art (kind ?ok) (register ?reg))
             (>= (count-doc-records [k employee_register] ?reg)
                 (lookup public_orgs kind ?ok employee_count 2))))
  (utility duty)
  (effects (maintain-proposal {@self TAKE_DOWN ?ad})))

(npc-think take_down_done
  ; ?ad ENUMERATED for the same reason as take_down_filled: the concluded
  ; take_down must clear ITS OWN post, not whichever post binds first.
  (role ?ad (believes {@self post ?ad ?org}))
  (when (any {@self TAKE_DOWN ?ad /succ} (out int)))
  (effects (end-belief {@self post ?ad ?org})))

(npc-think recruit_staff_tmp_p1
  (task {@self recruit_staff ?org})
  (role ?app [k application] (spatial @self hold))
  (effects (debug-print "RCP_APP app=?app")))

(npc-think recruit_staff_tmp_p2
  (task {@self recruit_staff ?org})
  (role ?out [k outgoing_mail_stack] (co-present ?out @self))
  (effects (debug-print "RCP_OUT out=?out")))

(npc-think recruit_staff_tmp_p3
  (task {@self recruit_staff ?org})
  (role ?app [k application] (spatial @self hold))
  (role ?out [k outgoing_mail_stack] (co-present ?out @self))
  (effects (debug-print "RCP_BOTH")))

(npc-think recruit_staff_tmp_p4
  (task {@self recruit_staff ?org})
  (role ?app [k application] (spatial @self hold))
  (when (any {?org record ?}).target: ?art)
  (effects (debug-print "RCP_ART art=?art")))

(npc-think recruit_staff_tmp_p5
  (task {@self recruit_staff ?org})
  (role ?app [k application] (spatial @self hold))
  (role ?home {@self home ?home})
  (effects (debug-print "RCP_P5")))

(npc-think recruit_staff_tmp_p6
  (task {@self recruit_staff ?org})
  (role ?app [k application] (spatial @self hold))
  (role ?home {@self home ?home})
  (role ?out [k outgoing_mail_stack])
  (effects (debug-print "RCP_P6")))

(npc-think recruit_staff_tmp_p7
  (task {@self recruit_staff ?org})
  (role ?home {@self home ?home})
  (role ?app [k application] (spatial @self hold))
  (effects (debug-print "RCP_P7")))

(npc-think recruit_staff_tmp_p8
  (task {@self recruit_staff ?org})
  (role ?h [k hand] (struct @self hand))
  (role ?home {@self home ?home})
  (effects (debug-print "RCP_P8")))

(npc-think recruit_staff_tmp_p15
  (task {@self recruit_staff ?org})
  (when (and (any {?org record ?}).target: ?art
             (read-doc-record [k articles_of_incorporation] ?art (building ?wp))
             (in-building @self ?wp)))
  (effects (debug-print "RCP_P15_INSIDE")))

(npc-think recruit_staff_tmp_p16
  (task {@self recruit_staff ?org})
  (when (and (any {?org record ?}).target: ?art
             (read-doc-record [k articles_of_incorporation] ?art (building ?wp))
             (>= (now-hour) 9)
             (< (now-hour) 11)))
  (effects (debug-print "RCP_P16_MAIL")))

(npc-think recruit_staff_tmp_p9
  (task {@self recruit_staff ?org})
  (role ?home {@self home ?home})
  (role ?out [k outgoing_mail_stack])
  (role ?app [k application] (spatial @self hold))
  (effects (debug-print "RCP_P9")))

(npc-think recruit_staff_tmp_p10
  (task {@self recruit_staff ?org})
  (role ?home {@self home ?home})
  (role ?out [k outgoing_mail_stack])
  (effects (debug-print "RCP_P10")))

(npc-think recruit_staff_tmp_p11
  (task {@self recruit_staff ?org})
  (role ?out [k outgoing_mail_stack])
  (role ?app [k application] (spatial @self hold))
  (effects (debug-print "RCP_P11")))

(npc-think recruit_staff_tmp_p12
  (task {@self recruit_staff ?org})
  (role ?home {@self home ?home})
  (role ?out [k outgoing_mail_stack])
  (role ?app [k application] (spatial @self hold))
  (when (in-building ?out ?home))
  (effects (debug-print "RCP_P12")))

(npc-think recruit_staff_tmp_p13
  (task {@self recruit_staff ?org})
  (role ?home {@self home ?home})
  (role ?out [k outgoing_mail_stack])
  (role ?app [k application] (spatial @self hold))
  (when (location ?out): ?room)
  (effects (debug-print "RCP_P13 room=?room")))

(npc-think recruit_staff_tmp_p14
  (task {@self recruit_staff ?org})
  (role ?home {@self home ?home})
  (role ?out [k outgoing_mail_stack] (not (co-present ?out @self)))
  (role ?app [k application] (spatial @self hold))
  (effects (debug-print "RCP_P14")))
