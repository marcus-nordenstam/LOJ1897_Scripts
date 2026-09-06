; ----------------------------------------------------------------------------
; post-ad ?org ?job - put a notice up on the parish board for ONE open post. The post
; is the parameter, so the notice knows what it advertises: the role is the post
; object's OWN kind, not a lookup in a staffing table the officer has no way of
; knowing, and an org with two distinct openings posts two distinct notices.
;
; A COMPOSITION of general lego acts (no bespoke POST_ADVERT):
;   CREATE-ENTITY [k job-description] : pen the notice (born on the church board);
;   WRITE ?ad (written-msg {?org display-ad ?job} {?org workplace ?wp})
;                                     : the whole notice in ONE act - what is on offer
;                                       and where to apply. The notice carries the SAME
;                                       sentence the org holds, so a seeker who READs
;                                       the board adopts the org's own fact; the
;                                       workplace sentence anchors the org for that
;                                       reader, so it must carry a BOUND ?wp - an
;                                       unbound one writes a hole and no seeker can act
;                                       on the advert.
;
; {?org display-ad ?job} is minted at the outcome and ended by remove-ad. The ended
; post-ad belief cannot serve: it says this instance posted once, not that a notice is
; standing, so it re-posts yesterday's opening and cannot span a shift.
; ----------------------------------------------------------------------------

(npc-task {@self post-ad ?org ?job}:?pad-rel
  (tar org)
  (aux job)
  (and
    ; The board is a church the officer KNOWS; knowing none, he searches the region for
    ; one (the find-building task), and gives up once that search has failed.
    (try
      (role ?board [k building church] (select (score (near @self ?board)) (policy roulette)))
      (when (not (spatial @self building ?board)))
      (effects (maintain-proposal {@self enter ?board})))
    (try
      (no-role [k building church])
      (when (and -{@self find-building [k building church] ? /fail}
                 (current-region @self): ?rg))
      (effects
               (maintain-proposal {@self find-building [k building church] ?rg})))
    (try
      (when (and (is-a (spatial @self building) [k building church])
                 -{@self CREATE-ENTITY [k job-description] /succ /caused_by ?pad-rel}))
      (effects
               (maintain-proposal {@self CREATE-ENTITY [k job-description]})))
    (try
      (role ?ad [k job-description] (spatial ?ad co-located @self)
            (not (substantial (attr ?ad writing))))
      (when {?org workplace ?wp})
      (effects
               (maintain-proposal {@self WRITE ?ad (written-msg {?org display-ad ?job}
                                                                {?org workplace ?wp})})))
    (try
      ; THIS run's sheet - /caused_by is right here and only here: the question is whether
      ; the act I just performed succeeded, not what stands on the board. Without it a
      ; second posting, for a second open post, concludes off the FIRST post's sheet: it
      ; finds a job-description @self has written, marks its own post advertised and never
      ; pens anything (measured: 3 postings, 1 sheet).
      (role ?ad [k job-description] (spatial ?ad co-located @self))
      (when {@self WRITE ?ad ? /succ /caused_by ?pad-rel})
      ; The notice is up: mint the standing fact, then conclude. Without an outcome the task
      ; never concludes and its board search (find-building -> locate -> wander) keeps the
      ; body at the SAME band the recruit-staff round bids at, so the officer can never leave
      ; to enter his own office - the round starved for the run.
      (effects
               (begin-belief {?org display-ad ?job})
               (set-outcome ?pad-rel /succ)))))
