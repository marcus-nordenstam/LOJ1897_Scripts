; ----------------------------------------------------------------------------
; club_join_errand (npc-think lane) - the THINK half of the club-joining split.
;
; The decision (clubs.hs `club_joining`) minted {@self goal {@self JOIN_CLUB
; <club_articles>}}. The member goes to the clubhouse and is enrolled on the roster
; there (npc-act/club_join_errand.hs). The club's articles are the goal focus (?art,
; bound off the {@self JOIN_CLUB} goal), so the clubhouse is (articles-building ?art).
;
;   join_go            : hold the goal, not at the clubhouse -> travel act to it.
;   join_at_clubhouse  : AT the clubhouse -> propose the join act (join_club_act reads the
;                        club articles off the standing goal). The decision (clubs.hs
;                        club_joining) owns the goal's whole life.
; ----------------------------------------------------------------------------

(npc-think join_go
  (goal {@self JOIN_CLUB ?art})
  (when (and (articles-building ?art ?venue)
             (not (in-building @self ?venue))))
  (utility 40)
  (effects (maintain-proposal {@self enter ?venue})))

; AT the clubhouse: PROPOSE the join act (goals never propose themselves). join_club_act reads the
; club articles off the standing {@self JOIN_CLUB} goal focus, so the propose is label-only.
(npc-think join_at_clubhouse
  (goal {@self JOIN_CLUB ?art})
  (when (and (articles-building ?art ?venue)
             (in-building @self ?venue)))
  (utility 40)
  (effects (maintain-proposal {@self JOIN_CLUB})))
