; ----------------------------------------------------------------------------
; club_found_errand (npc-action lane) - the ACT half of the club-founding split.
;
; The decision (clubs.hs `club_founding`) minted {@self goal {@self found_club}}.
; The founder goes out (npc-think lane) and founds the club at a pub;
; found-club-seq acquires the clubhouse, founds the org, and enrols him as its
; first member. Members join afterwards via club_joining.
; ----------------------------------------------------------------------------

(npc-action {@self found_club}
  (duration 90)
  (effects
    ; The foundable-club catalog, ungated (0): clubs are not premises-gated -
    ; a dry pool just no-ops the founding macro via its (if ?wp) guard.
    (tolerate (roll-org-kind 0
                   [k org race_club] [k org athletic_club]):?clubkind)
    (if ?clubkind (then (found-club-seq ?clubkind)))
    (set-outcome {@self found_club} succ)))
