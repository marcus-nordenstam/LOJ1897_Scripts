; ----------------------------------------------------------------------------
; recruit_staff ?org - the PERFORMANCE of the held recruit_staff duty ({@self duty_to ?org
; recruit_staff} is the obligation; the running task is doing it). Spawned by the running
; work task while the wage book is short of the org's authored headcount; concluded by the
; done try when the book fills. Tries: post an advert; a daily office round that READS the
; office mail (locate the mail room, duty-scan the applications into hand); RESOLVE the held
; batch (offer the first, reject the rest); the filled posting comes off the board via the
; standalone take_down lane (recruit_think.hs, post-belief driven). The tmp_pN tries are
; debug probes over the held-application / outbox state.
; ----------------------------------------------------------------------------

(npc-task {@self recruit_staff ?org}:?rec-rel
  (tar org)
  (and
    (try
      (when (and {?org isa ?ok}
                 {?org employee_register ?reg}
                 (>= (table-count ?reg)
                     (if (table-match public_orgs kind ?ok employee_count ?ec) (then ?ec) (else 2)))))
      (effects (set-outcome ?rec-rel /succ)))
    (try
      (when -{@self post ? ?org})
      (effects (debug-print "RC_ADPICK") (maintain-proposal {@self advertise ?org})))
    (try
      (when (and {?org workplace ?wp}
                 (not (spatial @self building ?wp))
                 (>= (days-since-last {@self read_mail ?wp /succ}) 1)))
      (utility obligation)
      (effects (debug-print "RC_GOOFC") (maintain-proposal {@self enter ?wp})))
    (try
      (lock-rule)
      (when (and {?org workplace ?wp}
                 (spatial @self building ?wp)
                 (>= (days-since-last {@self read_mail ?wp /succ}) 1)))
      (utility obligation)
      (effects (debug-print "RC_RDMAIL") (begin-proposal {@self read_mail ?wp})))
    (try
      (role ?home {@self home ?home})
      (role ?out [k outgoing_mail_stack] (not (spatial ?out co-located @self)))
      (role ?app [k application] (spatial @self hold)
            (select (policy first-match)))
      (when (and (spatial ?out building ?home)
                 (spatial ?out space): ?room))
      (utility obligation)
      (effects (debug-print "RC_RESGO") (maintain-proposal {@self WALK ?room})))
    ; READ each held application - adopt its {?applicant apply_for ?jk} - then consume it.
    (try
      (role ?app [k application] (spatial @self hold)
            -{@self READ ?app /succ})
      (utility obligation)
      (effects (debug-print "RC_READAPP") (maintain-proposal {@self READ ?app})))
    (try
      (role ?app [k application] (spatial @self hold)
            (any {@self READ ?app /succ}))
      (effects (debug-print "RC_DROPAPP") (maintain-proposal {@self DESTROY_ENTITY ?app})))
    ; RESOLVE the learned applicants: draft + mail a verdict to each.
    (try
      (lock-rule)
      (when (and {? apply_for ?}
                 (empty (spatial @self hold [k application]))
                 -{@self resolve_applications /pres}))
      (utility obligation)
      (effects (debug-print "RC_RESOLVE") (begin-proposal {@self resolve_applications})))
    (try
      (role ?app [k application] (spatial @self hold))
      (effects (debug-print "RCP_APP app=?app")))
    (try
      (role ?out [k outgoing_mail_stack] (spatial ?out co-located @self))
      (effects (debug-print "RCP_OUT out=?out")))
    (try
      (role ?app [k application] (spatial @self hold))
      (role ?out [k outgoing_mail_stack] (spatial ?out co-located @self))
      (effects (debug-print "RCP_BOTH")))
    (try
      (role ?app [k application] (spatial @self hold))
      (when {?org record ?art})
      (effects (debug-print "RCP_ART art=?art")))
    (try
      (role ?app [k application] (spatial @self hold))
      (role ?home {@self home ?home})
      (effects (debug-print "RCP_P5")))
    (try
      (role ?app [k application] (spatial @self hold))
      (role ?home {@self home ?home})
      (role ?out [k outgoing_mail_stack])
      (effects (debug-print "RCP_P6")))
    (try
      (role ?home {@self home ?home})
      (role ?app [k application] (spatial @self hold))
      (effects (debug-print "RCP_P7")))
    (try
      (role ?h [k hand] (spatial @self hand))
      (role ?home {@self home ?home})
      (effects (debug-print "RCP_P8")))
    (try
      (when (and {?org workplace ?wp}
                 (spatial @self building ?wp)))
      (effects (debug-print "RCP_P15_INSIDE")))
    (try
      (when (and {?org workplace ?wp}
                 (>= (now-hour) 9)
                 (< (now-hour) 11)))
      (effects (debug-print "RCP_P16_MAIL")))
    (try
      (role ?home {@self home ?home})
      (role ?out [k outgoing_mail_stack])
      (role ?app [k application] (spatial @self hold))
      (effects (debug-print "RCP_P9")))
    (try
      (role ?home {@self home ?home})
      (role ?out [k outgoing_mail_stack])
      (effects (debug-print "RCP_P10")))
    (try
      (role ?out [k outgoing_mail_stack])
      (role ?app [k application] (spatial @self hold))
      (effects (debug-print "RCP_P11")))
    (try
      (role ?home {@self home ?home})
      (role ?out [k outgoing_mail_stack])
      (role ?app [k application] (spatial @self hold))
      (when (spatial ?out building ?home))
      (effects (debug-print "RCP_P12")))
    (try
      (role ?home {@self home ?home})
      (role ?out [k outgoing_mail_stack])
      (role ?app [k application] (spatial @self hold))
      (when (spatial ?out space): ?room)
      (effects (debug-print "RCP_P13 room=?room")))
    (try
      (role ?home {@self home ?home})
      (role ?out [k outgoing_mail_stack] (not (spatial ?out co-located @self)))
      (role ?app [k application] (spatial @self hold))
      (effects (debug-print "RCP_P14")))))
