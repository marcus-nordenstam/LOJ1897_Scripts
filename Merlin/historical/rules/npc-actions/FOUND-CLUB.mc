; ----------------------------------------------------------------------------
; club_found_errand (npc-action lane) - the ACT half of the club-founding split.
;
; The decision (clubs.hs `club_founding`) minted {@self goal {@self FOUND-CLUB}}.
; The founder goes out (npc-think lane) and founds the club at a pub;
; found-club-seq acquires the clubhouse, founds the org, and enrols him as its
; first member. Members join afterwards via club_joining.
; ----------------------------------------------------------------------------

(npc-action {@self FOUND-CLUB}
  (duration 90)
  (effects
    ; Clubs are not premises-gated; a dry pool just no-ops found-club-seq's own
    ; (if ?wp) guard.
    (table-sample-weighted foundable_clubs kind weight): ?clubkind
    (if ?clubkind (then (found-club-seq ?clubkind)))
    (set-outcome {@self FOUND-CLUB} /succ)))
