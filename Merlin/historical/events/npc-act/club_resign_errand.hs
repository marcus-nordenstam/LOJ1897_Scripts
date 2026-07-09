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

(hsim-npc-behaviour resign_go
  (short-term-think)
  (goal {@self resign_club})
  ; The clubhouse is role-cast from the clubhouses the NPC KNOWS; nearest preferred,
  ; weighted. No known clubhouse -> no fire (the goal waits). Replaces (venue ...).
  (roles
    (role ?go_dest [k building social_clubhouse] (prefer (near @self ?go_dest)) (policy weighted)))
  (when (not (at-place-kind [k building social_clubhouse])))
  (utility 40)
  (effects (begin-act {@self go ?go_dest})))

(hsim-npc-behaviour resign_dwell
  (short-term-think)
  (goal {@self resign_club})
  (when (at-place-kind [k building social_clubhouse]))
  (utility 40)
  (effects (begin-act {@self resign_club} 45 resign_commit)))

(hsim-npc-behaviour resign_commit
  (on-completion)
  (effects
    (unregister-member /member @self)
    (end-goal {@self resign_club})
    ))
