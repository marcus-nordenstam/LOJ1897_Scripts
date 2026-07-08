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

(hsim-npc-behaviour join_go
  (short-term-think)
  (when (and (articles-building (goal-focus join_club) ?venue)
             (has-goal join_club)
             (not (at-place ?venue))))
  (utility 40)
  (effects (go @self ?venue)))

(hsim-npc-behaviour join_dwell
  (short-term-think)
  (when (and (articles-building (goal-focus join_club) ?venue)
             (has-goal join_club)
             (at-place ?venue)))
  (utility 40)
  (effects (act join_commit 60)))

(hsim-npc-behaviour join_commit
  (on-completion)
  (effects
    (register-member /articles (goal-focus join_club) /member @self)
    (end-goal {@self join_club})
    ))
