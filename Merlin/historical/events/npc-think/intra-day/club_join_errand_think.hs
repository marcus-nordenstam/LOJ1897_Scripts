; ----------------------------------------------------------------------------
; club_join_errand (npc-think lane) - the THINK half of the club-joining split.
;
; The decision (clubs.hs `club_joining`) minted {@self goal {@self join_club
; <club_articles>}}. The member goes to the clubhouse and is enrolled on the roster
; there (npc-act/club_join_errand.hs). The club's articles are the goal focus, so
; the clubhouse is (articles-building (goal-focus join_club)).
;
;   join_go : hold the goal, not at the clubhouse -> travel act to it. AT the clubhouse
;             the goal is the leaf and promotes to join_club_act - no dwell rung (the
;             decision, clubs_think.hs club_joining, owns the goal's whole life).
; ----------------------------------------------------------------------------

(npc-think join_go
  (schedule on-commit)
  (if-blocked hold)
  (goal {@self join_club})
  (when (and (articles-building (goal-focus join_club) ?venue)
             (not (in-building ?venue))))
  (utility 40)
  (effects       (begin-goal {@self enter ?venue}))
  (cease-effects (end-goal   {@self enter ?venue})))
