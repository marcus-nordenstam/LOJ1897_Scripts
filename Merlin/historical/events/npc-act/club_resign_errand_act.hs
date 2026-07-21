; ----------------------------------------------------------------------------
; club_resign_errand (npc-act lane) - the ACT half of the club-resignation split.
;
; The decision (clubs.hs `club_resignation`) minted {@self goal {@self
; resign_club}} (focusless - a man resigns from his own club). The member calls at
; a clubhouse (npc-think lane) and gives up his membership there; unregister-member
; resolves his own club from his member_of bond.
; ----------------------------------------------------------------------------

(npc-act resign_club_act
  (when (believes {@self resign_club}))
  (duration 45)
  (act-effects
    (unregister-member /member @self)
    (end-act {@self resign_club})))
