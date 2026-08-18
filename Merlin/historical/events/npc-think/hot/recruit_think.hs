; ----------------------------------------------------------------------------
; recruit - the ORG side of the labour market. The recruit_staff TASK stays npc-think here:
; its label is referenced as a KIND ([k recruit_staff]) by the duty tables, which load
; before the event pass mints npc-task heads, so its declaration must stay in Tasks.mon and
; the task cannot be an npc-task. The advertise subtask (npc-tasks/advertise-task.hs) and
; the work-spawn rung (npc-tasks/work-task.hs) DID migrate.
;
;   TASK recruit_staff ?org - the PERFORMANCE of the held recruit_staff duty. Spawned by
;   the running work task while the wage book is short; concluded when the book fills.
;   Rungs: post an advert; a daily office round that READS the office mail; RESOLVE the
;   held batch; take the filled posting off the board (the post-belief take_down lane).
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; Outcome twin: the wage book reached the org's authored headcount - the duty performance
; concluded (the standing OBLIGATION {@self duty_to ..} remains).
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

; --- the office round: while the office inbox holds mail he goes himself and READS it.
(npc-think recruit_staff_go_office
  (task {@self recruit_staff ?org})
  (when (and (any {?org record ?}).target: ?art
             (read-doc-record [k articles_of_incorporation] ?art (building ?wp))
             (not (in-building @self ?wp))
             (>= (days-since-last {@self read_mail ?wp /succ}) 1)))
  (utility obligation)
  (effects (debug-print "RC_GOOFC") (maintain-proposal {@self enter ?wp})))

(npc-think recruit_staff_read_mail
  (lock-rule)
  (task {@self recruit_staff ?org})
  (when (and (any {?org record ?}).target: ?art
             (read-doc-record [k articles_of_incorporation] ?art (building ?wp))
             (in-building @self ?wp)
             (>= (days-since-last {@self read_mail ?wp /succ}) 1)))
  (utility obligation)
  (effects (debug-print "RC_RDMAIL") (begin-proposal {@self read_mail ?wp})))

; --- holding gathered applications -> carry them to a known outgoing pile.
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

; --- holding gathered applications, standing at an outgoing pile -> run the verdict ROUND.
(npc-think recruit_staff_resolve
  (lock-rule)
  (task {@self recruit_staff ?org})
  (role ?out [k outgoing_mail_stack] (co-present ?out @self))
  (role ?app [k application] (spatial @self hold)
        (select (policy first-match)))
  (when (none {@self resolve_applications ?out /pres}))
  (utility obligation)
  (effects (debug-print "RC_RESOLVE") (begin-proposal {@self resolve_applications ?out})))

; --- the filled posting comes off the board (POST-BELIEF driven, not task-gated) --------
(npc-think take_down_filled
  ; ?ad ENUMERATED: an officer can hold several posted adverts at once, and a single @self
  ; bind would take the first post found and only ever test THAT ad's org.
  (role ?ad (believes {@self post ?ad ?org}))
  (when (and (any {?org record ?}).target: ?art
             (read-doc-record [k articles_of_incorporation] ?art (kind ?ok) (register ?reg))
             (>= (count-doc-records [k employee_register] ?reg)
                 (lookup public_orgs kind ?ok employee_count 2))))
  (utility duty)
  (effects (maintain-proposal {@self TAKE_DOWN ?ad})))

(npc-think take_down_done
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
