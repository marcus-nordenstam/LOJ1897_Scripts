; ----------------------------------------------------------------------------
; club_found_errand (npc-think lane) - the THINK half of the club-founding split.
;
; The decision (clubs.hs `club_founding`) minted {@self goal {@self found_club}}.
; The founder goes out (to a pub - the period's clubs grew out of tavern society)
; and founds the club there (npc-act/club_found_errand.hs).
;
;   found_club_go     : hold the goal, not at a pub -> travel act to one.
;   found_club_dwell  : hold the goal, AT a pub -> a dwell (the founding meeting).
; ----------------------------------------------------------------------------

(npc-think found_club_go
  (short-term-think)
  (goal {@self found_club})
  ; The pub is role-cast from the pubs the NPC KNOWS; nearest preferred, weighted.
  ; No known pub -> no fire (the goal waits). Replaces (venue ...).
  (role ?go_dest [k building pub] (select (score (near @self ?go_dest)) (policy roulette)))
  (when (not (at-place-kind [k building pub])))
  (utility 45)
  (cont-fire-effects (go-into ?go_dest)))

(npc-think found_club_dwell
  (short-term-think)
  (goal {@self found_club})
  (when (at-place-kind [k building pub]))
  (utility 45)
  (cont-fire-effects (begin-goal {@self found_club})))
