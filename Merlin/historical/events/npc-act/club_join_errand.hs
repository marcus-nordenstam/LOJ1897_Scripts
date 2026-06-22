; ----------------------------------------------------------------------------
; club_join_errand - the npc-ACT half of the club-joining split (Item 5).
;
; The decision (clubs.hs `club_joining`) minted {@self goal {@self join_club
; <club_articles>}}. The member goes to the clubhouse and is enrolled on the roster
; there - the co-presence the clubhouse's afforded events read, instead of a
; faceless roster edit. The club's articles are the goal focus, so the clubhouse is
; (articles-building (goal-focus join_club)).
;
;   join_go     : hold the goal, not at the clubhouse -> travel act to it.
;   join_dwell  : hold the goal, AT the clubhouse -> a dwell (being introduced).
;   join_commit : completion (completion-only) - registers the member + clears the goal.
; ----------------------------------------------------------------------------

(hsim-event join_go
  (intra-day)
  (nl   "@self sets out for a club")
  (let ((?venue (articles-building (goal-focus join_club))))
    (when (and (has-goal join_club)
               (not (at-place ?venue))))
    (utility 40)
    (effects (go @self ?venue))))

(hsim-event join_dwell
  (intra-day)
  (nl   "@self is introduced at a club")
  (let ((?venue (articles-building (goal-focus join_club))))
    (when (and (has-goal join_club)
               (at-place ?venue)))
    (utility 40)
    (effects (act join_commit 60))))

(hsim-event join_commit
  (schedule (completion-only))
  (nl   "@self joins a club")
  (effects
    (register-member :articles (goal-focus join_club) :member @self)
    (clear-goal @self join_club)
    (log _club_joining @self)))
