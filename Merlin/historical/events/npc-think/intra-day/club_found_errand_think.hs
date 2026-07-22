; ----------------------------------------------------------------------------
; club_found_errand (npc-think lane) - the THINK half of the club-founding split.
;
; The decision (clubs.hs `club_founding`) minted {@self goal {@self found_club}}.
; The founder goes out (to a pub - the period's clubs grew out of tavern society)
; and founds the club there (npc-act/club_found_errand.hs).
;
;   found_club_go : hold the goal, not at a pub -> travel act to one. AT a pub the
;                   goal is the leaf and promotes to found_club_act - no dwell rung
;                   (the decision, clubs.hs club_founding, owns the goal's whole life).
; ----------------------------------------------------------------------------

(npc-think found_club_go
  (schedule on-commit)
  (if-blocked hold)
  (goal {@self found_club})
  ; The pub is role-cast from the pubs the NPC KNOWS; nearest preferred, weighted.
  ; No known pub -> no fire (the goal waits). Replaces (venue ...).
  (role ?go_dest [k building pub] (select (score (near @self ?go_dest)) (policy roulette)))
  (when (not (at-place-kind [k building pub])))
  (utility 45)
  (effects       (begin-goal {@self enter ?go_dest}))
  (cease-effects (end-goal   {@self enter ?go_dest})))

; AT a pub: PROPOSE the founding act (goals never propose themselves). found_club_act reads its
; club details off the standing {@self found_club} goal, so the propose is label-only.
(npc-think found_club_at_pub
  (schedule on-commit)
  (if-blocked hold)
  (goal {@self found_club})
  (when (at-place-kind [k building pub]))
  (utility 45)
  (effects (maintain-proposal {@self found_club})))
