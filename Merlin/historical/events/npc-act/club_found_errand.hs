; ----------------------------------------------------------------------------
; club_found_errand - the npc-ACT half of the club-founding split (Item 5).
;
; The decision (clubs.hs `club_founding`) minted {@self goal {@self found_club}}.
; The founder goes out (to a pub - the period's clubs grew out of tavern society)
; and founds the club there; found-org spawns the clubhouse, founds the org, and
; enrols him. Members join afterwards via club_joining.
;
;   found_club_go     : hold the goal, not at a pub -> travel act to one.
;   found_club_dwell  : hold the goal, AT a pub -> a dwell (the founding meeting).
;   found_club_commit : completion (completion-only) - founds the club + clears the goal.
; ----------------------------------------------------------------------------

(hsim-event found_club_go
  (intra-day)
  (nl   "@self sets out to found a club")
  (when (and (has-goal found_club)
             (not (at-place-kind [k building pub]))))
  (utility 45)
  (effects (go @self (venue [k building pub]))))

(hsim-event found_club_dwell
  (intra-day)
  (nl   "@self gathers men to found a club")
  (when (and (has-goal found_club)
             (at-place-kind [k building pub])))
  (utility 45)
  (effects (act found_club_commit 90)))

(hsim-event found_club_commit
  (schedule (completion-only))
  (nl   "@self founds a club")
  (effects
    (found-org :kind club :founder @self)
    (clear-goal @self found_club)
    (log _club_founding @self)))
