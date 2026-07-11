; ----------------------------------------------------------------------------
; club_found_errand - the npc-ACT half of the club-founding split (Item 5).
;
; The decision (clubs.hs `club_founding`) minted {@self goal {@self found_club}}.
; The founder goes out (to a pub - the period's clubs grew out of tavern society)
; and founds the club there; found-club-seq acquires the clubhouse, founds the org,
; and enrols him as its first member. Members join afterwards via club_joining.
;
;   found_club_go     : hold the goal, not at a pub -> travel act to one.
;   found_club_dwell  : hold the goal, AT a pub -> a dwell (the founding meeting).
;   found_club_commit : completion (completion-only) - founds the club + clears the goal.
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

(npc-act found_club_act
  (when (believes {@self found_club}))
  (duration 90)
  (act-effects
    ; The foundable-club catalog, ungated (0): clubs are not premises-gated -
    ; a dry pool just no-ops the founding macro via its (if ?wp) guard.
    (roll-org-kind (bind ?clubkind) 0
                   [k org race_club] [k org athletic_club])
    (if ?clubkind (found-club-seq ?clubkind))
    (end-act {@self found_club})
    (end-goal {@self found_club})))
