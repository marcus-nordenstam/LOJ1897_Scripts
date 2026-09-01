; ----------------------------------------------------------------------------
; club_found_errand (npc-think lane) - the THINK half of the club-founding split.
;
; The decision (clubs.hs `club_founding`) minted {@self goal {@self FOUND-CLUB}}.
; The founder goes out (to a pub - the period's clubs grew out of tavern society)
; and founds the club there (npc-act/club_found_errand.hs).
;
;   found_club_go      : hold the goal, not at a pub -> travel act to one.
;   found_club_at_pub  : AT a pub -> propose the founding act (found_club_act reads its
;                        club details off the standing goal). The decision (clubs.hs
;                        club_founding) owns the goal's whole life.
; ----------------------------------------------------------------------------

(npc-think found_club_go
  (goal {@self FOUND-CLUB})
  ; The pub is role-cast from the pubs the NPC KNOWS; nearest preferred, weighted.
  ; No known pub -> no fire (the goal waits).
  (role ?go_dest [k building pub] (select (score (near @self ?go_dest)) (policy roulette)))
  (when (not (is-a (spatial @self building) [k building pub])))
  (effects (maintain-proposal {@self enter ?go_dest})))

; AT a pub: PROPOSE the founding act (goals never propose themselves). found_club_act reads its
; club details off the standing {@self FOUND-CLUB} goal, so the propose is label-only.
(npc-think found_club_at_pub
  (goal {@self FOUND-CLUB})
  (when (is-a (spatial @self building) [k building pub]))
  (effects (maintain-proposal {@self FOUND-CLUB})))
