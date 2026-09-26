; DORMANT - this lane never ran; revived on the form deeds / articles with its own gauntlet.
;; ----------------------------------------------------------------------------
;; club_found_errand (npc-action) - the ACT half of the club-founding split.
;;
;; The decision (clubs.mc `club_founding`) minted {@self goal {@self FOUND-CLUB}}.
;; The founder goes out (npc-think) and founds the club at a pub;
;; found-club-seq acquires the clubhouse, founds the org, and enrols him as its
;; first member. Members join afterwards via club_joining.
;; ----------------------------------------------------------------------------

;; foundable_clubs - the catalogs an NPC founding a concern draws from. One row
;; per foundable kind; `weight` biases the draw. Nothing here gates on premises:
;; found-org-seq's own (if ?wp) guard no-ops a founding with nowhere to house it,
;; so a kind with no free building simply produces nothing that trip.
;(define-table foundable_clubs
;  (fields kind weight)
;  (record [k org race-club]     1)
;  (record [k org athletic-club] 1))

;(npc-action {@self FOUND-CLUB}
;  (motor body legs)
;  (duration (seconds 90 min))
;  (effects
;    ; Clubs are not premises-gated; a dry pool just no-ops found-club-seq's own
;    ; (if ?wp) guard.
;    (table-sample-weighted foundable_clubs kind weight): ?clubkind
;    (if ?clubkind (then (found-club-seq ?clubkind)))
;    (set-outcome {@self FOUND-CLUB} /succ)))
