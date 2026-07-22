; ----------------------------------------------------------------------------
; club_join_errand (npc-action lane) - the ACT half of the club-joining split.
;
; The decision (clubs.hs `club_joining`) minted {@self goal {@self join_club
; <club_articles>}}. The member goes to the clubhouse (npc-think lane) and is
; enrolled on the roster there - the co-presence the clubhouse's afforded events
; read, instead of a faceless roster edit.
; ----------------------------------------------------------------------------

(npc-action join_club_act
  (act {@self join_club})
  (duration 60)
  (act-effects
    (register-member /articles (goal-focus join_club) /member @self)
    (end-act {@self join_club})))
