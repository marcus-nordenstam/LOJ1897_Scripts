; ----------------------------------------------------------------------------
; club_resign_errand (npc-think lane) - the THINK half of the club-resignation split.
;
; The decision (clubs.hs `club_resignation`) minted {@self goal {@self
; resign_club}} (focusless - a man resigns from his own club). The member calls at
; a clubhouse and gives up his membership there (npc-act/club_resign_errand.hs);
; the destination is any same-town clubhouse (by KIND, since (venue ...)
; random-picks per call).
;
;   resign_go : hold the goal, not at a clubhouse -> travel act to one. AT a clubhouse the
;               goal is the leaf and promotes to resign_club_act - no dwell rung (the
;               decision, clubs_think.hs club_resignation, owns the goal's whole life).
; ----------------------------------------------------------------------------

(npc-think resign_go
  (schedule on-commit)
  (if-blocked hold)
  (goal {@self resign_club})
  ; The clubhouse is role-cast from the clubhouses the NPC KNOWS; nearest preferred,
  ; weighted. No known clubhouse -> no fire (the goal waits). Replaces (venue ...).
  (role ?go_dest [k building social_clubhouse] (select (score (near @self ?go_dest)) (policy roulette)))
  (when (not (at-place-kind [k building social_clubhouse])))
  (utility 40)
  (effects       (begin-goal {@self enter ?go_dest}))
  (cease-effects (end-goal   {@self enter ?go_dest})))
