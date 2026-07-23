; ----------------------------------------------------------------------------
; club_resign_errand (npc-action lane) - the ACT half of the club-resignation split.
;
; The decision (clubs.hs `club_resignation`) minted {@self goal {@self
; resign_club}} (focusless - a man resigns from his own club). The member calls at
; a clubhouse (npc-think lane) and gives up his membership there; unregister-member
; resolves his own club from his member_of bond.
; ----------------------------------------------------------------------------

(npc-action resign_club_act
  (act {@self resign_club})
  (duration 45)
  (act-effects
    (unregister-member /member @self)
    (set-outcome {@self resign_club} succ)))
