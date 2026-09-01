; ----------------------------------------------------------------------------
; recruit-staff ?org - the PERFORMANCE of the held recruit-staff duty ({@self duty-to ?org
; recruit-staff} is the obligation; the running task is doing it). Spawned by the running
; work task while the wage book is short of the org's authored headcount; concluded by the
; done try when the book fills. Tries: post an advert; a daily office round that READS the
; office mail (locate the mail room, duty-scan the applications into hand); RESOLVE the held
; batch (offer the first, reject the rest); the filled posting comes off the board via the
; standalone take_down lane (recruit_think.hs, post-belief driven). The tmp_pN tries are
; debug probes over the held-application / outbox state.
; ----------------------------------------------------------------------------

(npc-task {@self recruit-staff ?org}:?rec-rel
  (track-skill-level [k personnel])
  (tar org)
  (and
    (try
      (when (and {?org isa ?ok}
                 {?org employee-register ?reg}
                 (>= (table-count ?reg)
                     (if (table-match public_orgs kind ?ok employee-count ?ec) (then ?ec) (else 2)))))
      (effects (set-outcome ?rec-rel /succ)))
    (try
      (when -{@self post ? ?org})
      (effects (maintain-proposal {@self advertise ?org})))
    (try
      (when (and {?org workplace ?wp}
                 (not (spatial @self building ?wp))
                 (>= (days-since-last {@self read-mail ?wp /succ}) 1)))
      (utility obligation)
      (effects (maintain-proposal {@self enter ?wp})))
    (try
      (lock-rule)
      (when (and {?org workplace ?wp}
                 (spatial @self building ?wp)
                 (>= (days-since-last {@self read-mail ?wp /succ}) 1)))
      (utility obligation)
      (effects (begin-proposal {@self read-mail ?wp})))
    (try
      (role ?home {@self home ?home})
      (role ?out [k outgoing-mail-stack] (not (spatial ?out co-located @self)))
      (role ?app [k application] (spatial @self hold)
            (select (policy first-match)))
      (when (and (spatial ?out building ?home)
                 (spatial ?out space): ?room))
      (utility obligation)
      (effects (maintain-proposal {@self WALK ?room})))
    ; READ each held application - adopt its {?applicant apply-for ?jk} - then consume it.
    (try
      (role ?app [k application] (spatial @self hold)
            -{@self READ ?app /succ})
      (utility obligation)
      (effects (maintain-proposal {@self READ ?app})))
    (try
      (role ?app [k application] (spatial @self hold)
            (any {@self READ ?app /succ}))
      (effects (maintain-proposal {@self DESTROY-ENTITY ?app})))
    ; RESOLVE the learned applicants: draft + mail a verdict to each.
    (try
      (lock-rule)
      (when (and {? apply-for ?}
                 (empty (spatial @self hold [k application]))
                 -{@self resolve-applications /pres}))
      (utility obligation)
      (effects (begin-proposal {@self resolve-applications})))
    (try
      (role ?app [k application] (spatial @self hold))
      (effects ))
    (try
      (role ?out [k outgoing-mail-stack] (spatial ?out co-located @self))
      (effects ))
    (try
      (role ?app [k application] (spatial @self hold))
      (role ?out [k outgoing-mail-stack] (spatial ?out co-located @self))
      (effects ))
    (try
      (role ?app [k application] (spatial @self hold))
      (when {?org record ?art})
      (effects ))
    (try
      (role ?app [k application] (spatial @self hold))
      (role ?home {@self home ?home})
      (effects ))
    (try
      (role ?app [k application] (spatial @self hold))
      (role ?home {@self home ?home})
      (role ?out [k outgoing-mail-stack])
      (effects ))
    (try
      (role ?home {@self home ?home})
      (role ?app [k application] (spatial @self hold))
      (effects ))
    (try
      (role ?h [k hand] (spatial @self hand))
      (role ?home {@self home ?home})
      (effects ))
    (try
      (when (and {?org workplace ?wp}
                 (spatial @self building ?wp)))
      (effects ))
    (try
      (when (and {?org workplace ?wp}
                 (>= (now-hour) 9)
                 (< (now-hour) 11)))
      (effects ))
    (try
      (role ?home {@self home ?home})
      (role ?out [k outgoing-mail-stack])
      (role ?app [k application] (spatial @self hold))
      (effects ))
    (try
      (role ?home {@self home ?home})
      (role ?out [k outgoing-mail-stack])
      (effects ))
    (try
      (role ?out [k outgoing-mail-stack])
      (role ?app [k application] (spatial @self hold))
      (effects ))
    (try
      (role ?home {@self home ?home})
      (role ?out [k outgoing-mail-stack])
      (role ?app [k application] (spatial @self hold))
      (when (spatial ?out building ?home))
      (effects ))
    (try
      (role ?home {@self home ?home})
      (role ?out [k outgoing-mail-stack])
      (role ?app [k application] (spatial @self hold))
      (when (spatial ?out space): ?room)
      (effects ))
    (try
      (role ?home {@self home ?home})
      (role ?out [k outgoing-mail-stack] (not (spatial ?out co-located @self)))
      (role ?app [k application] (spatial @self hold))
      (effects ))))
