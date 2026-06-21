; ----------------------------------------------------------------------------
; club_resign_errand - the npc-ACT half of the club-resignation split (Item 5).
;
; The decision (clubs.hs `club_resignation`) minted {@self goal {@self
; resign_club}} (focusless - a man resigns from his own club). The member calls at
; a clubhouse and gives up his membership there; unregister-member resolves his own
; club from his member_of bond, so the destination is any same-town clubhouse (by
; KIND, since (venue ...) random-picks per call).
;
;   resign_go     : hold the goal, not at a clubhouse -> travel act to one.
;   resign_dwell  : hold the goal, AT a clubhouse -> a short dwell.
;   resign_commit : completion (completion-only) - unregisters the member + clears goal.
; ----------------------------------------------------------------------------

(hsim-event resign_go
  (intra-day)
  (nl   "@self sets out to resign from a club")
  (when (and (has-goal resign_club)
             (not (self-at [k building social_clubhouse]))))
  (utility 40)
  (effects (go @self (venue [k building social_clubhouse]))))

(hsim-event resign_dwell
  (intra-day)
  (nl   "@self calls at his club")
  (when (and (has-goal resign_club)
             (self-at [k building social_clubhouse])))
  (utility 40)
  (effects (act resign_commit 45)))

(hsim-event resign_commit
  (schedule (completion-only))
  (nl   "@self resigns from a club")
  (effects
    (unregister-member :member @self)
    (clear-goal @self resign_club)
    (log _club_resignation @self)))
